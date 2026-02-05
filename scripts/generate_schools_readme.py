import json

with open("assets/schools.json") as f:
    schools = json.load(f)

table = [
    "| School | URL |",
    "| --- | --- |"
]

for school in schools:
    name = school.get("name", "")
    url = school.get("url", "")
    url_text = url.replace("https://", "")
    
    table.append(f"| {name} | [{url_text}]({url}) |")

with open("README.md") as f:
    readme = f.read()

start = "<!-- schools_start -->"
end = "<!-- schools_end -->"

above = readme.split(start)[0]
below = readme.split(end)[1]

new_readme = above + start + "\n" + "\n".join(table) + "\n" + end + below

with open("README.md", "w") as f:
    f.write(new_readme)
