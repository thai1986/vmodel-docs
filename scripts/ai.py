import xml.etree.ElementTree as ET
from pathlib import Path

xml_path = Path(__file__).with_name("example.arxml")
try:
    tree = ET.parse(xml_path)
except ET.ParseError as exc:
    raise SystemExit(f"Invalid XML in {xml_path}: {exc}")

root = tree.getroot()
ns = {"ar": "http://autosar.org/schema/r4.0"}
swcs = root.findall(".//ar:APPLICATION-SOFTWARE-COMPONENT-TYPE", ns)

for swc in swcs:
    name = swc.findtext("ar:SHORT-NAME", default="<unnamed>", namespaces=ns)
    print(f"\nSWC: {name}")

    for port in swc.findall(".//ar:P-PORT-PROTOTYPE", ns):
        port_name = port.findtext("ar:SHORT-NAME", default="<unnamed>", namespaces=ns)
        print("  P-Port:", port_name)

    for port in swc.findall(".//ar:R-PORT-PROTOTYPE", ns):
        port_name = port.findtext("ar:SHORT-NAME", default="<unnamed>", namespaces=ns)
        print("  R-Port:", port_name)

print(f"\nTotal SWC: {len(swcs)}")
