<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Fuzûlî Digital Edition</title>
                <style>
                <![CDATA[
                    :root {
                        --bg-main: #f4f1ea; --bg-card: #ffffff; --text-primary: #2c3e50;
                        --accent: #800000; --border: #ccc; --shadow: rgba(0,0,0,0.2);
                        --note-bg: #f9f9f9; --note-border: #3498db;
                    }

                    #darkToggle:checked ~ .site-wrapper {
                        --bg-main: #121212 !important; --bg-card: #1e1e1e !important;
                        --text-primary: #e0e0e0 !important; --accent: #ff4d4d !important;
                        --border: #333 !important; --note-bg: #252525 !important;
                    }

                    body { margin: 0; padding: 0; font-family: 'Georgia', serif; background-color: var(--bg-main); transition: 0.3s; }
                    .site-wrapper { min-height: 100vh; padding: 20px; color: var(--text-primary); background-color: var(--bg-main); transition: 0.3s; }
                    
                    .header-section { text-align: center; border-bottom: 3px double var(--accent); margin-bottom: 40px; padding: 20px; }
                    .search-container { max-width: 600px; margin: 20px auto; }
                    #poemSearch {
                        width: 100%; padding: 12px 20px; border-radius: 25px; border: 2px solid var(--accent);
                        background: var(--bg-card); color: var(--text-primary); font-size: 16px; outline: none;
                    }

                    .nav-controls { display: flex; justify-content: center; gap: 10px; margin-top: 25px; flex-wrap: wrap; }
                    .btn {
                        background: var(--accent); color: white !important; padding: 10px 18px; 
                        border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 13px;
                        border: none; transition: 0.2s; text-decoration: none; user-select: none;
                    }
                    .btn:hover { opacity: 0.9; transform: translateY(-2px); }

                    .modal-overlay {
                        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                        background: rgba(0,0,0,0.85); display: none; z-index: 9999; 
                        align-items: center; justify-content: center; backdrop-filter: blur(5px);
                    }
                    .modal-content {
                        background: var(--bg-card); color: var(--text-primary);
                        width: 90%; max-width: 900px; max-height: 85vh; padding: 40px; 
                        border-radius: 8px; position: relative; overflow-y: auto; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
                    }
                    .close-modal { position: absolute; top: 15px; right: 20px; font-size: 28px; cursor: pointer; color: var(--accent); font-weight: bold; }

                    #dashToggle:checked ~ .site-wrapper #dashModal,
                    #aboutToggle:checked ~ .site-wrapper #aboutModal { display: flex !important; }
                    
                    #dashToggle, #aboutToggle, #langToggle, #darkToggle, #noteToggle { display: none; }

                    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
                    .stat-box { background: var(--note-bg); padding: 20px; border-radius: 8px; text-align: center; border: 1px solid var(--border); }
                    .stat-box big { display: block; font-size: 2.5em; color: var(--accent); font-weight: bold; }
                    
                    .word-freq-container { margin-top: 30px; text-align: left; }
                    .word-tag { 
                        display: inline-block; background: var(--accent); color: white; 
                        padding: 3px 8px; margin: 3px; border-radius: 4px; font-size: 0.9em; 
                    }
                    .word-count { background: rgba(255,255,255,0.2); padding: 0 5px; margin-left: 5px; border-radius: 3px; font-size: 0.8em; }

                    .page-container { 
                        display: flex; background: var(--bg-card); margin-bottom: 50px; padding: 25px; 
                        border-radius: 8px; box-shadow: 0 4px 15px var(--shadow); max-width: 1200px; 
                        margin-left: auto; margin-right: auto; border: 1px solid var(--border);
                    }
                    .manuscript-side { flex: 1; padding: 10px; border-right: 1px solid var(--border); text-align: center; }
                    .manuscript-side img { width: 100%; max-width: 500px; border-radius: 4px; }
                    .text-side { flex: 1; padding: 30px; }
                    .couplet { margin-bottom: 40px; padding-bottom: 20px; border-bottom: 1px dashed var(--border); }
                    .tr-text { font-style: italic; font-size: 1.2em; line-height: 1.6; }
                    .tr-text span { display: block; margin-bottom: 5px; }
                    .en-text { display: none; border-left: 4px solid var(--accent); padding-left: 15px; margin-top: 10px; color: var(--text-primary); opacity: 0.9; }
                    .commentary-box { display: none; background: var(--note-bg); border-left: 4px solid var(--note-border); padding: 15px; margin-top: 15px; font-size: 0.9em; }

                    #langToggle:checked ~ .site-wrapper .tr-text { display: none; }
                    #langToggle:checked ~ .site-wrapper .en-text { display: block; }
                    #noteToggle:checked ~ .site-wrapper .commentary-box { display: block; }

                    #langToggle:not(:checked) ~ .site-wrapper .lang-btn:after { content: "Translation Mode"; }
                    #langToggle:checked ~ .site-wrapper .lang-btn:after { content: "Transcription Mode"; }
                    #noteToggle:not(:checked) ~ .site-wrapper .note-btn:after { content: "Show Notes"; }
                    #noteToggle:checked ~ .site-wrapper .note-btn:after { content: "Hide Notes"; }
                    #darkToggle:not(:checked) ~ .site-wrapper .dark-btn:after { content: "🌙 Dark"; }
                    #darkToggle:checked ~ .site-wrapper .dark-btn:after { content: "☀️ Light"; }
                ]]>
                </style>
            </head>
            <body>
                <input type="checkbox" id="dashToggle" />
                <input type="checkbox" id="aboutToggle" />
                <input type="checkbox" id="langToggle" />
                <input type="checkbox" id="noteToggle" />
                <input type="checkbox" id="darkToggle" />
                
                <div class="site-wrapper">
                    <div class="header-section">
                        <h1 style="color: var(--accent); font-size: 2.5em;">Kasîde-i Bahâriyye</h1>
                        <p>Digital Humanities Project | Fuzûlî Edition</p>

                        <div class="search-container">
                            <input type="text" id="poemSearch" placeholder="Search for words (e.g. gül, mey, spring)..." />
                        </div>

                        <div class="nav-controls">
                            <label for="dashToggle" class="btn" style="background:#2c3e50;">📊 Open Dashboard</label>
                            <label for="aboutToggle" class="btn">ℹ️ About</label>
                            <label for="langToggle" class="btn lang-btn"></label>
                            <label for="noteToggle" class="btn note-btn"></label>
                            <label for="darkToggle" class="btn dark-btn"></label>
                        </div>
                    </div>

                    <div id="dashModal" class="modal-overlay">
                        <div class="modal-content">
                            <label for="dashToggle" class="close-modal">×</label>
                            <h2 style="color:var(--accent); border-bottom: 2px solid var(--accent); padding-bottom:10px;">Project Statistics</h2>
                            
                            <div class="stats-grid">
                                <div class="stat-box">
                                    <big><xsl:value-of select="count(//tei:lg)"/></big>
                                    <small>Total Couplets</small>
                                </div>
                                <div class="stat-box">
                                    <big><xsl:value-of select="count(//tei:pb)"/></big>
                                    <small>Folios</small>
                                </div>
                                <div class="stat-box">
                                    <big><xsl:value-of select="count(//tei:note[@type='commentary'])"/></big>
                                    <small>Scholarly Notes</small>
                                </div>
                            </div>

                            <div class="word-freq-container">
                                <h3 style="color:var(--accent);">Word Frequency (Top Words)</h3>
                                <div id="wordCloud">Calculating vocabulary...</div>
                            </div>
                        </div>
                    </div>

                    <div id="aboutModal" class="modal-overlay">
                        <div class="modal-content">
                            <label for="aboutToggle" class="close-modal">×</label>
                            <h2 style="color:var(--accent); border-bottom: 2px solid var(--accent);">About This Project</h2>
                            <p>This digital edition of Fuzûlî's "Bahar Kasîdesi" was developed by <strong>Mehmet Eray Avcı</strong> and <strong>Uğur Can Yıldız</strong> for the "Manuscripts and Digital Humanities" course at FU Berlin.</p>
                        </div>
                    </div>

                    <div id="mainContent">
                        <xsl:for-each select="//tei:pb">
                            <div class="page-container">
                                <div class="manuscript-side">
                                    <img src="{@facs}" alt="Manuscript Page"/>
                                    <div style="margin-top:10px; font-weight:bold; color:var(--accent);">FOLIO: <xsl:value-of select="@n"/></div>
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
                                                <xsl:value-of select="tei:note[@type='translation']"/>
                                            </div>
                                            <xsl:if test="tei:note[@type='commentary']">
                                                <div class="commentary-box">
                                                    <strong style="color:var(--note-border);">NOTE:</strong><br/>
                                                    <xsl:value-of select="tei:note[@type='commentary']"/>
                                                </div>
                                            </xsl:if>
                                        </div>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </xsl:for-each>
                    </div>
                </div>

                <script>
                <![CDATA[
                    document.getElementById('poemSearch').addEventListener('input', function(e) {
                        const s = normalizeText(e.target.value.toLowerCase());
                        document.querySelectorAll('.couplet').forEach(c => {
                            const match = normalizeText(c.innerText.toLowerCase()).includes(s);
                            c.style.display = match ? "block" : "none";
                        });
                        document.querySelectorAll('.page-container').forEach(p => {
                            const hasMatch = Array.from(p.querySelectorAll('.couplet')).some(c => c.style.display !== "none");
                            p.style.display = hasMatch ? "flex" : "none";
                        });
                    });

                    function calculateFrequency() {
                        const text = document.getElementById('mainContent').innerText;
                        const words = text.toLowerCase()
                                          .replace(/[.,\/#!$%\^&\*;:{}=\-_`~()]/g,"")
                                          .split(/\s+/);
                        
                        const freq = {};
                        words.forEach(w => {
                            if (w.length > 3) {
                                freq[w] = (freq[w] || 0) + 1;
                            }
                        });

                        const sorted = Object.entries(freq)
                                             .sort((a,b) => b[1] - a[1])
                                             .slice(0, 30);

                        const cloud = document.getElementById('wordCloud');
                        cloud.innerHTML = sorted.map(([word, count]) => 
                            `<span class="word-tag">${word} <span class="word-count">${count}</span></span>`
                        ).join('');
                    }

                    function normalizeText(t) {
                        return t.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                                .replace(/[âā]/g, "a").replace(/[îī]/g, "i").replace(/[ûū]/g, "u")
                                .replace(/ḥ/g, "h").replace(/ṣ/g, "s").replace(/ż/g, "z")
                                .replace(/İ/g, "i").replace(/I/g, "i");
                    }

                    window.onload = calculateFrequency;
                ]]>
                </script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
