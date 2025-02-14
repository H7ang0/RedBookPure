import hashlib
import sys

def generate_activation_code(redbook_id, secret_key):
    content = f"{redbook_id}_{secret_key}"
    md5_hash = hashlib.md5(content.encode()).hexdigest()
    return md5_hash[:8].upper()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python generate_code.py <redbook_id>")
        sys.exit(1)
    
    redbook_id = sys.argv[1]
    secret_key = "YOUR_SECRET_KEY"  # 替换为相同的密钥
    
    code = generate_activation_code(redbook_id, secret_key)
    print(f"RedBook ID: {redbook_id}")
    print(f"Activation Code: {code}") 