import shutil
import sys
import os

def is_comment_in_text(input_text, index):
    sq = 0
    dq = 0
    for c in input_text[0:index]:
        if c == '\'':
            sq = sq + 1
        if c == '\"':
            dq = dq + 1
    return (sq % 2 == 1) and (dq % 2 == 1)

def copy_and_edit_file(input_file):
    base, ext = os.path.splitext(input_file)
    output_file = f"{base}.edit{ext}"
    shutil.copyfile(input_file, output_file)
    with open(output_file, 'r') as file:
        lines = file.readlines()
    
    edited_lines = []
    for line in lines:
        if line.lstrip().startswith("--"):
            continue
        if "--" in line:
            index = line.find("--")
            if is_comment_in_text(line,index):
                continue
            edited_lines.append(line[0:index].strip()+"\n")
        else:
            edited_lines.append(line)

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

