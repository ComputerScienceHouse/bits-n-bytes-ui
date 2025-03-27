from setuptools import setup, find_packages

with open("requirements.txt", "r") as f:
    requirements = f.read().splitlines()

setup(
    name="bnb",  # Name of your package
    version="0.1",
    packages=find_packages(),
    install_requires=requirements,  # Add any dependencies here
    entry_points={
        'console_scripts': [
            'bnb = bnb.main:app',
        ],
    },
)
