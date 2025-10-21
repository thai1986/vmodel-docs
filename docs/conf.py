import os
import sys
sys.path.insert(0, os.path.abspath('.'))

project = 'V-Model AUTOSAR Docs'
author = 'Hoang'
release = '0.1'

extensions = [
    'sphinx_needs',
    'sphinx_rtd_theme',
]

html_theme = 'sphinx_rtd_theme'

needs_types = [
    {'directive': 'need', 'title': 'Requirement', 'prefix': 'REQ', 'color': '#FFCC00', 'style': 'node'},
    {'directive': 'need', 'title': 'Specification', 'prefix': 'DES', 'color': '#00CCFF', 'style': 'node'},
    {'directive': 'need', 'title': 'Test Case', 'prefix': 'TC', 'color': '#66CC66', 'style': 'node'},
    {'directive': 'need', 'title': 'Validation', 'prefix': 'VAL', 'color': '#FF6666', 'style': 'node'},
]

needs_extra_options = ['derived_from', 'tests', 'validates']

needs_flow_show = True
needs_flow_configs = {
    'V-Model': {
        'start': ['requirement'],
        'end': ['test_case', 'validation'],
        'style': 'dot',
    }
}
