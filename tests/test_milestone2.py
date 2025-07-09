# tests/milestone2_tests.py

import requests
import os
import sys
import time
import subprocess
import json
import uuid

# Add the project root to the Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

def get_terraform_output(output_name):
    """
    Retrieves a specific output value from the Terraform state.
    Assumes `terraform output -json` can be run from the project root.
    """
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            capture_output=True,
            text=True,
            cwd=os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
        )
        outputs = json.loads(result.stdout)
        if output_name in outputs:
            return outputs[output_name]['value']
        else:
            print(f"Error: Terraform output '{output_name}' not found.")
            return None
    except subprocess.CalledProcessError as e:
        print(f"Error running 'terraform output -json': {e.stderr}")
        print("Please ensure Terraform has been applied successfully and you are running this script from the project root.")
        return None
    except json.JSONDecodeError as e:
        print(f"Error decoding terraform output JSON: {e}")
        return None
    except FileNotFoundError:
        print("Error: 'terraform' command not found. Please ensure Terraform is installed and in your PATH.")
        return None

def test_1_register_user_success(api_gateway_url, user_id):
    """
    Test 1: Send PUT to /register with valid userId, expect 200 and success message.
    """
    register_url = f"{api_gateway_url}/register?userId={user_id}"
    print(f"  Attempting to register user: {user_id} via PUT {register_url}")
    try:
        response = requests.put(register_url)
        response.raise_for_status()
        assert response.status_code == 200
        assert "application/json" in response.headers.get("Content-Type", "")
        response_json = response.json()
        assert response_json.get("message") == f"Registered User Successfully"
        print(f"  SUCCESS: User '{user_id}' registered successfully.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"  FAILURE: Request failed - {e}")
    except (json.JSONDecodeError, AssertionError) as e:
        print(f"  FAILURE: Invalid response - {e}. Response: {getattr(response, 'text', '')}")
    return False

def test_2_verify_user_success(api_gateway_url, user_id):
    """
    Test 2: Send GET to /verify with registered userId, expect 200 and index.html content.
    """
    verify_url = f"{api_gateway_url}/verify?userId={user_id}"
    print(f"  Attempting to verify registered user: {user_id} via GET {verify_url}")
    time.sleep(2)
    try:
        response = requests.get(verify_url)
        response.raise_for_status()
        assert response.status_code == 200
        assert "text/html" in response.headers.get("Content-Type", "")
        assert "User Verified Successfully!" in response.text
        print(f"  SUCCESS: User '{user_id}' verified successfully (received index.html).")
        return True
    except requests.exceptions.RequestException as e:
        print(f"  FAILURE: Request failed - {e}")
    except AssertionError as e:
        print(f"  FAILURE: Invalid response content or status - {e}. Response: {getattr(response, 'text', '')}")
    return False

def test_3_verify_user_not_found(api_gateway_url, user_id):
    """
    Test 3: Send GET to /verify with non-registered userId, expect error.html content.
    """
    verify_url = f"{api_gateway_url}/verify?userId={user_id}"
    print(f"  Attempting to verify non-existent user: {user_id} via GET {verify_url}")
    try:
        response = requests.get(verify_url)
        assert response.status_code == 200
        assert "text/html" in response.headers.get("Content-Type", "")
        assert "Error: User Not Found or Invalid Request" in response.text
        print(f"  SUCCESS: Non-existent user '{user_id}' verification failed as expected (received error.html).")
        return True
    except requests.exceptions.RequestException as e:
        print(f"  FAILURE: Request failed - {e}")
    except AssertionError as e:
        print(f"  FAILURE: Unexpected response for non-existent user - {e}. Response: {getattr(response, 'text', '')}")
    return False

def test_4_register_user_invalid_request(api_gateway_url):
    """
    Test 4: Send PUT to /register with missing userId, expect 400 Bad Request.
    """
    register_url = f"{api_gateway_url}/register"
    print(f"  Attempting to register with invalid query string (missing userId) via PUT {register_url}")
    try:
        response = requests.put(register_url)
        assert response.status_code == 400
        assert "Missing query parameters. Cannot register user." in response.text
        print("  SUCCESS: Invalid registration request correctly returned 400 Bad Request.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"  FAILURE: Request failed - {e}")
    except (json.JSONDecodeError, AssertionError) as e:
        print(f"  FAILURE: Unexpected response for invalid registration - {e}. Response: {getattr(response, 'text', '')}")
    return False

def test_5_verify_user_invalid_request(api_gateway_url):
    """
    Test 5: Send GET to /verify with missing userId, expect 400 Bad Request.
    """
    verify_url = f"{api_gateway_url}/verify"
    print(f"  Attempting to verify with invalid query string (missing userId) via GET {verify_url}")
    try:
        response = requests.get(verify_url)
        assert response.status_code == 400
        assert "Missing query parameters. Cannot verify user." in response.text
        print("  SUCCESS: Invalid verification request correctly returned 400 Bad Request.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"  FAILURE: Request failed - {e}")
    except AssertionError as e:
        print(f"  FAILURE: Unexpected response for invalid verification - {e}. Response: {getattr(response, 'text', '')}")
    return False

def run_all_tests():
    api_gateway_url = get_terraform_output("api_gateway_invoke_url")
    if not api_gateway_url:
        print("Could not retrieve API Gateway URL from Terraform outputs.")
        return

    # Generate unique user IDs for test independence
    user_id = f"testuser-{uuid.uuid4().hex[:8]}"
    non_existent_user_id = f"nouser-{uuid.uuid4().hex[:8]}"

    print("\nRunning Milestone 2 Automated Tests:\n")

    results = []
    results.append(("Register User Success", test_1_register_user_success(api_gateway_url, user_id)))
    results.append(("Verify User Success", test_2_verify_user_success(api_gateway_url, user_id)))
    results.append(("Verify User Not Found", test_3_verify_user_not_found(api_gateway_url, non_existent_user_id)))
    results.append(("Register User Invalid Request", test_4_register_user_invalid_request(api_gateway_url)))
    results.append(("Verify User Invalid Request", test_5_verify_user_invalid_request(api_gateway_url)))

    print("\nTest Results:")
    for name, result in results:
        print(f"  {name}: {'PASSED' if result else 'FAILED'}")

    if all(result for _, result in results):
        print("\nAll Milestone 2 tests PASSED!")
    else:
        print("\nSome Milestone 2 tests FAILED. Please check the output above for details.")

if __name__ == "__main__":
    run_all_tests()