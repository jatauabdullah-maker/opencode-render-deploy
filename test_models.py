#!/usr/bin/env python3
"""
Test script to verify free models work on deployed opencode server.
Run after deployment: python test_models.py https://your-app.onrender.com
"""
import sys
import json
import subprocess
import os

def test_model(server_url, model, prompt="Say 'OK' and nothing else"):
    """Test a single model via opencode run --attach"""
    # Extract host for auth if password is set
    auth_url = server_url
    if "OPENCODE_SERVER_PASSWORD" in os.environ:
        # Render sets this automatically, but we can pass via env
        pass
    
    cmd = [
        "opencode", "run",
        "--attach", server_url,
        "--auto",
        "-m", model,
        "--format", "json",
        prompt
    ]
    
    print(f"\nTesting {model}...")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        if result.returncode == 0:
            # Parse NDJSON output
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    try:
                        obj = json.loads(line)
                        if obj.get("type") == "text":
                            text = (obj.get("part") or {}).get("text", "").strip()
                            if text:
                                print(f"  ✓ Response: {text[:100]}")
                                return True
                    except json.JSONDecodeError:
                        continue
            print(f"  ✗ No text response")
            return False
        else:
            print(f"  ✗ Failed: {result.stderr[:200]}")
            return False
    except subprocess.TimeoutExpired:
        print(f"  ✗ Timeout")
        return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def test_websearch(server_url):
    """Test websearch capability via agent"""
    cmd = [
        "opencode", "run",
        "--attach", server_url,
        "--auto",
        "--agent", "web-researcher",
        "--format", "json",
        "What is the latest version of Python? Return JSON only."
    ]
    
    print(f"\nTesting websearch via web-researcher agent...")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=90)
        if result.returncode == 0:
            for line in result.stdout.strip().split('\n'):
                if line.strip():
                    try:
                        obj = json.loads(line)
                        if obj.get("type") == "text":
                            text = (obj.get("part") or {}).get("text", "").strip()
                            if text:
                                print(f"  ✓ Response received")
                                # Try to parse as JSON
                                try:
                                    parsed = json.loads(text)
                                    print(f"  ✓ Valid JSON response with keys: {list(parsed.keys())}")
                                except:
                                    print(f"  Response: {text[:200]}")
                                return True
                    except json.JSONDecodeError:
                        continue
            print(f"  ✗ No text response")
            return False
        else:
            print(f"  ✗ Failed: {result.stderr[:200]}")
            return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python test_models.py <server-url>")
        print("Example: python test_models.py https://opencode-headless.onrender.com")
        sys.exit(1)
    
    server_url = sys.argv[1].rstrip('/')
    
    # Free models to test (from opencode.jsonc whitelist)
    models = [
        "opencode/deepseek-v4-flash-free",
        "opencode/hy3-free",
        "opencode/nemotron-3-ultra-free",
        "nvidia/nemotron-3-ultra-550b-a55b",
        "nvidia/nemotron-3-super-120b-a12b",
    ]
    
    print(f"Testing free models on {server_url}")
    print("=" * 50)
    
    results = {}
    for model in models:
        results[model] = test_model(server_url, model)
    
    # Test websearch
    results["websearch"] = test_websearch(server_url)
    
    print("\n" + "=" * 50)
    print("SUMMARY:")
    for model, success in results.items():
        status = "✓ PASS" if success else "✗ FAIL"
        print(f"  {status}: {model}")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    print(f"\nTotal: {passed}/{total} passed")
    
    if passed == total:
        print("\n🎉 All tests passed!")
        sys.exit(0)
    else:
        print(f"\n⚠️  {total - passed} test(s) failed")
        sys.exit(1)

if __name__ == "__main__":
    main()