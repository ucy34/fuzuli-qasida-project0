<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Fuzûlî Digital Edition</title>
                <style>
                    :root {
                        --bg-main: #f4f1ea; --bg-card: #ffffff; --text-primary: #2c3e50;
                        --accent: #800000; --border: #ccc; --shadow: rgba(0,0,0,0.1);
                        --note-bg: #f9f9f9; --note-border: #3498db;
                    }

                    #darkToggle:checked ~ .site-wrapper {
                        --bg-main: #121212 !important;
                        --bg-card: #1e1e1e !important;
                        --text-primary: #e0e0e0 !important;
                        --accent: #ff4d4d !important;
                        --border: #333 !important;
                        --note-bg: #252525 !important;
                    }

                    body { margin: 0; padding: 0; font-family: 'Georgia', serif; background-color: var(--bg-main); transition: 0.3s; }
                    .site-wrapper { min-height: 100vh; padding: 20px; color: var(--text-primary); background-color: var(--bg-main); transition: 0.3s; }
                    
                    /* ARAMA BÖLÜMÜ */
                    .search-section {
                        max-width: 600px;
                        margin: 20px auto;
                    }
                    #searchInput {
                        width: 100%;
                        padding: 12px 20px;
                        border-radius: 25px;
                        border: 2px solid var(--border);
                        background: var(--bg-card);
                        color: var(--text-primary);
                        font-size: 16px;
                        outline: none;
                        transition: 0.3s;
                        box-sizing: border-box;
                    }
                    #searchInput:focus { border-color: var(--accent); box-shadow: 0 0 10px var(--shadow); }

                    .nav-controls { display: flex; flex-direction: row; justify-content: center; gap: 15px; margin-top: 25px; flex-wrap: wrap; }

                    .btn {
                        background: var(--accent); color: white !important; padding: 10px 18px; 
                        border-radius: 4px; box-shadow: 0 4px 6px var(--shadow); 
                        font-weight: bold; cursor: pointer; font-size: 13px; text-align: center;
                        user-select: none; border: none; transition: 0.2s; text-decoration: none;
                    }
                    .btn:hover { opacity: 0.9; transform: translateY(-2px); }

                    .about-overlay {
                        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                        background: rgba(0,0,0,0.85); display: none; z-index: 9999; 
                        align-items: center; justify-content: center; backdrop-filter: blur(5px);
                    }
                    .about-content {
                        background: var(--bg-card); color: var(--text-primary);
                        width: 90%; max-width: 850px; max-height: 85vh; padding: 40px; 
                        border-radius: 8px; position: relative; overflow-y: auto; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
                    }
                    .close-about { position: absolute; top: 15px; right: 20px; font-size: 28px; cursor: pointer; color: var(--accent); font-weight: bold; }
                    
                    .faq-item {
                        background: var(--note-bg); padding: 20px; border-radius: 6px;
                        margin-bottom: 20px; border-left: 4px solid var(--accent); text-align: left;
                    }
                    .faq-item h3 { margin-top: 0; color: var(--accent); font-size: 1.1em; }

                    #aboutToggle:checked ~ .site-wrapper .about-overlay { display: flex !important; }
                    #langToggle, #darkToggle, #noteToggle, #aboutToggle { display: none; }

                    #langToggle:not(:checked) ~ .site-wrapper .lang-btn:after { content: "Show English Translation"; }
                    #langToggle:checked ~ .site-wrapper .lang-btn:after { content: "Show Turkish Transcription"; }
                    #noteToggle:not(:checked) ~ .site-wrapper .note-btn:after { content: "Show Scholarly Notes"; }
                    #noteToggle:checked ~ .site-wrapper .note-btn:after { content: "Hide Scholarly Notes"; }
                    #darkToggle:not(:checked) ~ .site-wrapper .dark-btn:after { content: "🌙 Dark Mode"; }
                    #darkToggle:checked ~ .site-wrapper .dark-btn:after { content: "☀️ Light Mode"; }

                    .header-section { text-align: center; border-bottom: 3px double var(--accent); margin-bottom: 40px; padding: 20px; }
                    .page-container { 
                        display: flex; flex-direction: row; background: var(--bg-card); 
                        margin-bottom: 50px; padding: 25px; border-radius: 8px; 
                        box-shadow: 0 4px 15px var(--shadow); max-width: 1200px; 
                        margin-left: auto; margin-right: auto; border: 1px solid var(--border);
                    }
                    .manuscript-side { flex: 1; padding: 10px; border-right: 1px solid var(--border); text-align: center; }
                    .manuscript-side img { width: 100%; max-width: 500px; border-radius: 4px; border: 1px solid var(--border); }
                    .text-side { flex: 1; padding: 30px; }

                    .couplet { margin-bottom: 50px !important; padding-bottom: 25px; border-bottom: 1px dashed var(--border); display: block; }
                    .couplet:last-child { border-bottom: none; margin-bottom: 0; }
                    .tr-text { display: block; line-height: 1.8; font-style: italic; font-size: 1.2em; }
                    .en-text { display: none; font-size: 1.1em; border-left: 5px solid var(--accent); padding-left: 20px; line-height: 1.8; }
                    .tr-text span, .en-text span { display: block; margin-bottom: 12px; }

                    .commentary-box {
                        display: none; margin-top: 15px; padding: 12px;
                        background-color: var(--note-bg); border-left: 4px solid var(--note-border);
                        font-size: 0.9em; font-family: sans-serif;
                    }
                    
                    #langToggle:checked ~ .site-wrapper .tr-text { display: none; }
                    #langToggle:checked ~ .site-wrapper .en-text { display: block; }
                    #noteToggle:checked ~ .site-wrapper .commentary-box { display: block; }
                    .folio-label { font-weight: bold; color: var(--accent); display: block; margin-top: 15px; }
                </style>
                
                <script>
                    function searchFunction() {
                        let input = document.getElementById('searchInput').value.toLowerCase();
                        
                        // Transkripsiyon karakterlerini normal harflere çeviren yardımcı fonksiyon
                        const normalizeText = (str) => {
                            return str.toLowerCase()
                                .replace(/[āâ]/g, 'a')
                                .replace(/[īî]/g, 'i')
                                .replace(/[ūû]/g, 'u')
                                .replace(/[ḥ]/g, 'h')
                                .replace(/[ṣ]/g, 's')
                                .replace(/[żż]/g, 'z')
                                .replace(/[ṭ]/g, 't')
                                .replace(/[’‘']/g, '');
                        };

                        let normalizedInput = normalizeText(input);
                        let couplets = document.getElementsByClassName('couplet');
                        let pages = document.getElementsByClassName('page-container');

                        for (let i = 0; i &lt; couplets.length; i++) {
                            let rawText = couplets[i].innerText;
                            let normalizedCoupletText = normalizeText(rawText);

                            if (normalizedCoupletText.includes(normalizedInput)) {
                                couplets[i].style.display = ""; 
                            } else {
                                couplets[i].style.display = "none"; 
                            }
                        }

                        // Sayfa içinde hiç görünür beyit kalmadıysa sayfayı gizle
                        for (let j = 0; j &lt; pages.length; j++) {
                            let visibleItems = pages[j].querySelectorAll('.couplet:not([style*="display: none"])');
                            if (visibleItems.length === 0) {
                                pages[j].style.display = "none";
                            } else {
                                pages[j].style.display = "flex";
                            }
                        }
                    }
                </script>
            </head>
            <body>
                <input type="checkbox" id="langToggle" />
                <input type="checkbox" id="noteToggle" />
                <input type="checkbox" id="darkToggle" />
                <input type="checkbox" id="aboutToggle" />
                
                <div class="site-wrapper">
                    <div class="header-section">
                        <h1 style="color: var(--accent);">Kasîde-i Bahâriyye</h1>
                        <p>Digital Humanities Edition | Mehmet Eray Avcı &amp; Uğur Can Yıldız</p>
                        
                        <div class="search-section">
                            <input type="text" id="searchInput" onkeyup="searchFunction()" placeholder="Kelime ara (Örn: bahar, hülle, rose)..."/>
                        </div>

                        <div class="nav-controls">
                            <label for="aboutToggle" class="btn">About This Project</label>
                            <label for="langToggle" class="btn lang-btn"></label>
                            <label for="noteToggle" class="btn note-btn"></label>
                            <label for="darkToggle" class="btn dark-btn"></label>
                        </div>
                    </div>

                    <div class="about-overlay">
                        <div class="about-content">
                            <label for="aboutToggle" class="close-about">×</label>
                            <h2 style="color:var(--accent); text-align:left; border-bottom: 2px solid var(--accent); padding-bottom: 10px;">About This Project</h2>
                            <p>This website was designed by two FU Berlin ISME Students, namely <strong>Mehmet Eray Avcı</strong> and <strong>Uğur Can Yıldız</strong>. It was developed under the final requirement of Dr. Christian Casey's course "Manuscripts and Digital Humanities."</p>
                            <p>The manuscript access is via TBMM Archives.</p>
                            
                            <h2 style="color:var(--accent); text-align:left; border-bottom: 2px solid var(--accent); padding-bottom: 10px; margin-top: 30px;">FAQ</h2>
                            <div class="faq-item">
                                <h3>1. What is Divan Literature?</h3>
                                <p>Divan literature is the classical tradition of Ottoman poetry and prose.</p>
                            </div>
                        </div>
                    </div>

                    <xsl:for-each select="//tei:pb">
                        <div class="page-container">
                            <div class="manuscript-side">
                                <img src="{@facs}" alt="Manuscript Page"/>
                                <span class="folio-label">Folio: <xsl:value-of select="@n"/></span>
                            </div>
                            <div class="text-side">
                                <xsl:for-each select="following-sibling::tei:div[1]/tei:lg">
                                    <div class="couplet">
                                        <div class="tr-text">
                                            <xsl:for-each select="tei:l">
                                                <span><xsl:value-of select="."/></span>
                                            </xsl:for-each>
                                        </div>
                                        <div class="en-text">
                                            <span><xsl:value-of select="tei:note[@type='translation'] | tei:quote"/></span>
                                        </div>
                                        <xsl:if test="tei:note[@type='commentary']">
                                            <div class="commentary-box">
                                                <strong style="color:var(--note-border); font-size:0.8em;">COMMENTARY</strong><br/>
                                                <xsl:value-of select="tei:note[@type='commentary']"/>
                                            </div>
                                        </xsl:if>
                                    </div>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
