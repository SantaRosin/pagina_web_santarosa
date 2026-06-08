import json

# --- ESCUELAS ---
with open('00_Data_Lake/pagina_web_santarosa/_esc_logos.json') as f:
    esc_logos = json.load(f)

with open('00_Data_Lake/pagina_web_santarosa/pag_fichas_escuelas.html', 'r', encoding='utf-8') as f:
    html = f.read()

js_lines = []
for rbd, b64 in sorted(esc_logos.items(), key=lambda x: x[0]):
    js_lines.append('    "' + rbd + '": "' + b64 + '"')
js_logos = 'var LOGOS = {\n' + ',\n'.join(js_lines) + '\n};'

html = html.replace(
    'var LOGO_BASE = "../../07_graficas_instituciones/01.logos_establecimientos/";',
    js_logos
)

# Replace the img src line
html = html.replace(
    """'<img src="' + LOGO_BASE + e.rbd + '.' + e.ext + '" alt="' + e.nombre + '" loading="lazy" ' +""",
    """'<img src="' + (LOGOS[e.rbd] || "") + '" alt="' + e.nombre + '" loading="lazy" ' +"""
)

with open('00_Data_Lake/pagina_web_santarosa/pag_fichas_escuelas.html', 'w', encoding='utf-8') as f:
    f.write(html)
print("Escuelas: " + str(len(esc_logos)) + " logos embedded, HTML size: " + str(len(html)//1024) + " KB")

# --- JARDINES ---
with open('00_Data_Lake/pagina_web_santarosa/_jar_logos.json') as f:
    jar_logos = json.load(f)

with open('00_Data_Lake/pagina_web_santarosa/pag_fichas_jardines.html', 'r', encoding='utf-8') as f:
    html2 = f.read()

js_lines2 = []
for rbd, b64 in sorted(jar_logos.items(), key=lambda x: x[0]):
    js_lines2.append('    "' + rbd + '": "' + b64 + '"')
js_logos2 = 'var LOGOS = {\n' + ',\n'.join(js_lines2) + '\n};'

html2 = html2.replace(
    'var LOGO_BASE = "../../07_graficas_instituciones/02_logos_jardines/";',
    js_logos2
)
html2 = html2.replace(
    'var FALLBACK_IMG = "../../07_graficas_instituciones/02_logos_jardines/imagen-no-disponible.c3ae8808.jpg";',
    'var FALLBACK_IMG = "";'
)

# Replace the imgSrc line
html2 = html2.replace(
    'var imgSrc = j.ext === "none" ? FALLBACK_IMG : LOGO_BASE + j.rbd + "." + j.ext;',
    'var imgSrc = LOGOS[j.rbd] || FALLBACK_IMG;'
)

# Replace onerror fallback
html2 = html2.replace(
    """'onerror="this.src=\\'' + FALLBACK_IMG + '\\'">""" + "' +",
    """'onerror="this.style.display=\\'none\\'">""" + "' +"
)

with open('00_Data_Lake/pagina_web_santarosa/pag_fichas_jardines.html', 'w', encoding='utf-8') as f:
    f.write(html2)
print("Jardines: " + str(len(jar_logos)) + " logos embedded, HTML size: " + str(len(html2)//1024) + " KB")
