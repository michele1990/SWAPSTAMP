import os

def list_files_with_content(folder_path):
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path):
            print(filename)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    print(content)
            except Exception as e:
                print(f"Could not read file: {e}")
            print()  # Add a blank line between files

# Example usage:
folder = "/Users/northwestwind/Desktop/SWAPSTAMP/infrastructure"
list_files_with_content(folder)
