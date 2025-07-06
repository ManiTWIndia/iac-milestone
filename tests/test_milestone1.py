import requests
import sys
import json

def test_endpoint(api_url):
    """Tests the / endpoint of the API Gateway."""
    try:
        print(f"Testing URL: {api_url}/")
        response = requests.get(f"{api_url}/")
        response.raise_for_status()

        print(f"Status Code: {response.status_code}")
        assert response.status_code == 200

        data = response.json()
        print(f"Response JSON: {data}")
        assert data.get("message") == "Hello world"

        print("✅ Test PASSED!")

    except Exception as e:
        print(f"❌ Test FAILED: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_milestone1.py <api_gateway_url>")
        sys.exit(1)

    url = sys.argv[1].strip('/')
    test_endpoint(url)