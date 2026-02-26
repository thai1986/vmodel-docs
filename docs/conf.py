"""Sphinx configuration for TRAVEO II Entry Family Starter Kit documentation."""

project = "TRAVEO II Entry Family Starter Kit"
author = "Infineon Technologies / Cypress Semiconductor"
release = "002-25314 Rev. *B"
language = "en"

extensions = [
    "sphinx.ext.autodoc",
    "sphinx_rtd_theme",
]

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]

exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]
