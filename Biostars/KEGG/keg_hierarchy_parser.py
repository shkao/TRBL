import re
import requests


def extract_category_from_line(line, prefix):
    """Extracts the category text from a line given the prefix."""
    return line.strip().split(" ", 1)[1]


def extract_path_from_line(line):
    """Extracts the path from the line, removing the bracketed path expression."""
    category_text = re.sub(r" \[PATH:ko\d+\]", "", line.strip().split(" ", 1)[1])
    path_search = re.search(r"\[PATH:(ko\d+)\]", line)
    path = path_search.group(1) if path_search else ""
    return category_text, path


def extract_ko_and_ec_numbers(line):
    """Extracts the KO number and EC number from the line."""
    parts = line.strip().split(" ", 2)
    ko_number = parts[1]
    ko_name_ec = parts[2].rsplit(" [EC:", 1)
    ko_name = ko_name_ec[0]
    ec_number = "EC:" + ko_name_ec[1][:-1] if len(ko_name_ec) > 1 else ""
    return ko_number, ko_name, ec_number


def parse_keg_to_tsv(url, output_file_path):
    response = requests.get(url)
    response.raise_for_status()  # Ensure we notice bad responses
    keg_data = response.text.splitlines()

    with open(output_file_path, "w") as outfile:
        category_a = category_b = category_c = ""
        for line in keg_data:
            if line.startswith("A"):
                category_a = extract_category_from_line(line, "A")
            elif line.startswith("B  "):
                category_b = extract_category_from_line(line, "B")
            elif line.startswith("C    "):
                category_c, path = extract_path_from_line(line)
            elif line.startswith("D      "):
                ko_number, ko_name, ec_number = extract_ko_and_ec_numbers(line)
                outfile.write(
                    f"{category_a}\t{category_b}\t{path}\t{category_c}\t{ko_number}\t{ko_name}\t{ec_number}\n"
                )


# Call the function with the URL and output file path
parse_keg_to_tsv(
    "http://www.genome.jp/kegg-bin/download_htext?htext=ko00001.keg&format=htext&filedir=",
    "KO.tsv",
)
