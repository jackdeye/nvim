import shutil
import sys
import os

def copy_and_edit_file(input_file):
    # Create the output file name by appending ".edit" to the input file name
    base, ext = os.path.splitext(input_file)
    output_file = f"{base}.edit{ext}"

    # Copy the input file to the output file
    shutil.copyfile(input_file, output_file)

    # Open the output file for reading and writing
    with open(output_file, 'r') as file:
        lines = file.readlines()

    # Edit each line (example: convert to uppercase)
    # edited_lines = [line.upper() for line in lines]

    # Write the edited lines back to the output file
    with open(output_file, 'w') as file:
        file.writelines(edited_lines)

    print(f"File '{input_file}' has been copied and edited to '{output_file}'")

if __name__ == "__main__":
    # Check if the script was called with the correct number of arguments
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_file>")
        sys.exit(1)

    # Get the input file from the command line arguments
    input_file = sys.argv[1]

    # Call the function to copy and edit the file
    copy_and_edit_file(input_file)

