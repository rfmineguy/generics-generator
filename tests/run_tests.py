import os
import subprocess
import hashlib

def test_linked_list_T(T):
    print("generics-generator", "linked_list", f'--datatype="{T}"', "--outputdir=output")
    subprocess.run(["generics-generator", "linked_list", "--datatype", T, "--outputdir=output"])
    T = T.replace(' ', '_')
    subprocess.run(["gcc", "-c", f'output/linked_list_{T}.c'])

def main():
    os.environ['GEN_TEMPLATE_PATH'] = 'templates'
    test_linked_list_T("int")
    test_linked_list_T("long int")

if __name__ == "__main__":
    main()
