# debug_sympy_lark.py
import sys
import sympy
import inspect
import pkgutil

print(f"Python version: {sys.version}")
print(f"SymPy version: {sympy.__version__}")

# Try to import Lark
try:
    import lark
    print(f"Lark version: {lark.__version__}")
except ImportError:
    print("Lark not installed")

# Check for latex parsing modules in sympy
print("\nChecking sympy.parsing modules:")
if hasattr(sympy, 'parsing'):
    print("sympy.parsing exists")
    if hasattr(sympy.parsing, 'latex'):
        print("sympy.parsing.latex exists")
        
        # List all modules in sympy.parsing.latex
        print("\nModules in sympy.parsing.latex:")
        for _, name, is_pkg in pkgutil.iter_modules(sympy.parsing.latex.__path__, 
                                                   'sympy.parsing.latex.'):
            print(f"- {name}")
        
        # Check for parse_latex function
        if hasattr(sympy.parsing.latex, 'parse_latex'):
            print("\nparse_latex function exists in sympy.parsing.latex")
            print(f"Function signature: {inspect.signature(sympy.parsing.latex.parse_latex)}")
            print(f"Function doc: {sympy.parsing.latex.parse_latex.__doc__}")
        else:
            print("\nparse_latex function NOT found in sympy.parsing.latex")

# Try different import paths that might contain the Lark parser
possible_paths = [
    'sympy.parsing.latex.lark_parser',
    'sympy.parsing.latex._lark_parser',
    'sympy.parsing.latex.parser',
    'sympy.parsing.latex._parser'
]

print("\nTrying to import possible modules:")
for path in possible_paths:
    try:
        module = __import__(path, fromlist=[''])
        print(f"Successfully imported {path}")
        
        # Check if this module has parse_latex
        if hasattr(module, 'parse_latex'):
            print(f"- Found parse_latex in {path}")
            print(f"- Function signature: {inspect.signature(module.parse_latex)}")
        else:
            print(f"- No parse_latex function in {path}")
            
    except ImportError as e:
        print(f"Failed to import {path}: {e}")

# Try direct import of parse_latex
print("\nTrying to use parse_latex with various backends:")
try:
    from sympy.parsing.latex import parse_latex
    print("Successfully imported parse_latex from sympy.parsing.latex")
    
    # Try with default backend
    try:
        result = parse_latex(r"\frac{1}{2}")
        print(f"Default backend result: {result}")
    except Exception as e:
        print(f"Error with default backend: {e}")
    
    # Try with lark backend
    try:
        result = parse_latex(r"\frac{1}{2}", backend="lark")
        print(f"Lark backend result: {result}")
    except Exception as e:
        print(f"Error with lark backend: {e}")
        
except ImportError as e:
    print(f"Failed to import parse_latex: {e}")
