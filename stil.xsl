<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Fuzûlî Digital Edition</title>
                <style>
                    :root {
                        --bg-main: #f4f1ea;
                        --bg-card: #ffffff; 
                        --text-primary: #2c3e50;
                        --accent: #800000; 
                        --border: #ccc; 
                        --shadow: rgba(0,0,0,0.1);
                        --note-bg: #f9f9f9; 
                        --note-border: #3498db;
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
                    
                    /* SEARCH SECTION */
                    .search-section { max-width: 600px; margin: 20px auto; }
                    #searchInput {
                        width: 100%; padding: 12px 20px; border-radius: 25px;
                        border: 2px solid var(--border); background: var(--bg-card);
                        color: var(--text-primary); font-size: 16px; outline: none; box-sizing: border-box;
                    }

                    /* GLOSSARY TOOLTIP */
                    .glossary-term {
                        border-bottom: 2px dotted var(--accent); cursor: help;
                        position: relative; display: inline-block; color: inherit;
                    }
                    .glossary-term:hover::after {
                        content: attr(data-meaning); position: absolute;
                        bottom: 125%; left: 50%; transform: translateX(-50%);
                        background-color: #333; color: #fff; padding: 8px 12px;
                        border-radius: 6px; font-size: 0.85em; z-index: 1000; min-width: 150px; text-align: center;
                    }

                    .nav-controls { display: flex; justify-content: center; gap: 15px; margin-top: 25px; }
                    .btn {
                        background: var(--accent); color: white !important; padding: 10px 18px; 
                        border-radius: 4px; font-weight: bold; cursor: pointer; font-size: 13px; text-decoration: none;
                    }

                    /* ABOUT SECTION */
                    .about-overlay {
                        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                        background: rgba(0,0,0,0.85); display: none; z-index: 9999; 
                        align-items: center; justify-content: center; backdrop-filter: blur(5px);
                    }
                    #aboutToggle:checked ~ .site-wrapper .about-overlay { display: flex !important; }
                    .about-content { background: var(--bg-card); width: 90%; max-width: 850px; padding: 40px; border-radius: 8px; }

                    #langToggle, #darkToggle, #noteToggle, #aboutToggle { display: none; }
                    #langToggle:not(:checked) ~ .site-wrapper .lang-btn:after { content: "Show English Translation"; }
                    #langToggle:checked ~ .site-wrapper .lang-btn:after { content: "Show Turkish Transcription"; }
                    #noteToggle:not(:checked) ~ .site-wrapper .note-btn:after { content: "Show Scholarly Notes"; }
                    #noteToggle:checked ~ .site-wrapper .note-btn:after { content: "Hide Scholarly Notes"; }
                    #darkToggle:not(:checked) ~ .site-wrapper .dark-btn:after { content: "🌙 Dark Mode"; }
                    #darkToggle:checked ~ .site-wrapper .dark-btn:after { content: "☀️ Light Mode"; }

                    /* PAGE STRUCTURE */
                    .header-section { text-align: center; border-bottom: 3px double var(--accent); margin-bottom: 40px; padding: 20px; }
                    .page-container { 
                        display: flex; flex-direction: row; background: var(--bg-card); 
                        margin-bottom: 50px; padding: 25px; border-radius: 8px; 
                        max-width: 1250px; margin-left: auto; margin-right: auto; border: 1px solid var(--border);
                    }
                    .manuscript-side { flex: 0 0 45%; padding: 10px; border-right: 1px solid var(--border); }
                    .manuscript-side img { width: 100%; border-radius: 4px; }
                    .text-side { flex: 1; padding: 20px 30px; }

                    /* POETRY ALIGNMENT ENGINE - FIXED MIRROR LAYOUT */
                    .couplet { 
                        margin-bottom: 35px !important; 
                        padding-bottom: 20px; 
                        border-bottom: 1px dashed var(--border);
                        width: 100%;
                    }
                    
                    .tr-text { 
                        display: grid; 
                        grid-template-columns: 1fr 1fr; /* Two symmetrical columns */
                        column-gap: 40px; /* Consistent space between hemistichs */
                        margin-bottom: 15px;
                    }

                    .tr-text span { 
                        display: block; 
                        font-style: italic; 
                        font-size: 1.25em; 
                        line-height: 1.5;
                        width: 100%;
                    }

                    /* Mirror effect: Hemistich 'a' aligns to center-right, 'b' to center-left */
                    .tr-text span:nth-child(1) { text-align: right; }
                    .tr-text span:nth-child(2) { text-align: left; }

                    .en-text { 
                        display: none; font-size: 1.1em; border-left: 4px solid var(--accent); 
                        padding: 10px 20px; background: var(--note-bg); margin-top: 15px;
                    }

                    .commentary-box {
                        display: none; margin-top: 15px; padding: 15px;
                        background-color: var(--note-bg); border-left: 4px solid var(--note-border);
                        font-size: 0.95em;
                    }
                    
                    #langToggle:checked ~ .site-wrapper .tr-text { display: none; }
                    #langToggle:checked ~ .site-wrapper .en-text { display: block; }
                    #noteToggle:checked ~ .site-wrapper .commentary-box { display: block; }
                    .folio-label { font-weight: bold; color: var(--accent); display: block; margin-top: 15px; font-size: 1.1em; }
                </style>
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
                            <input type="text" id="searchInput" onkeyup="searchFunction()" placeholder="Search terms..."/>
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
                            <label for="aboutToggle" style="float:right; cursor:pointer; font-weight:bold;">Close ×</label>
                            <h2>About This Project</h2>
                            <p>Developed by Mehmet Eray Avcı and Uğur Can Yıldız for FU Berlin Digital Humanities course.</p>
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
                                                <span><xsl:apply-templates select="node()"/></span>
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
                <script>
                    function searchFunction() {
                        let input = document.getElementById('searchInput').value.toLowerCase();
                        let couplets = document.getElementsByClassName('couplet');
                        for (let i = 0; i &lt; couplets.length; i++) {
                            if (couplets[i].innerText.toLowerCase().includes(input)) { couplets[i].style.display = ""; } 
                            else { couplets[i].style.display = "none"; }
                        }
                    }
                </script>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="tei:term">
        <span class="glossary-term" data-meaning="{@meaning}">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
</xsl:stylesheet>
