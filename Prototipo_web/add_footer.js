const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

const footerHtml = `
        <footer class="h-8 bg-slate-100/90 border-t border-slate-200/80 px-4 flex items-center justify-between text-[11px] text-slate-500 shrink-0 select-none">
            <div class="flex items-center gap-3">
                <span class="flex items-center gap-1.5">
                    <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                    <span>Repositórios ativos: Flathub, Ubuntu APT, Snapcraft</span>
                </span>
            </div>
            <div class="flex items-center gap-4">
                <span>Pronto</span>
                <div class="h-3 w-[1px] bg-slate-300"></div>
                <span>Armazenamento livre: 142.4 GB</span>
            </div>
        </footer>`;

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Check if footer already exists
    if (!content.includes('<footer class="h-8 bg-slate-100/90')) {
        // Find the closing div of the main window wrapper
        // The structure is typically:
        //             </main>
        //         </div>
        // 
        //     <!-- JS Render Logic
        
        // We want to insert the footer right after the inner flex container 
        // (<div class="flex-1 flex overflow-hidden">) which is closed by </div> 
        // before the final closing </div> of the main window.
        // Actually, looking at teste.html:
        //         </div>
        // 
        //         <footer class="...">...</footer>
        //     </div>
        //
        //     <script>...
        
        // Let's replace the last </div> before <script> or <!-- JS
        content = content.replace(/(<\/div>\s*)(<!-- JS Render Logic|<\/script>|<script>)/, `$1${footerHtml}\n    </div>\n\n    $2`);
        
        // Wait, the regex might replace the outer div. 
        // Let's do it safer.
        // The structure usually is:
        //             </main>
        //         </div>
        //     </div>
        //     <script>
        // Let's just find "</main>\n        </div>\n    </div>"
        content = content.replace(/<\/main>\s*<\/div>\s*<\/div>/, `</main>\n        </div>${footerHtml}\n    </div>`);

        fs.writeFileSync(file, content, 'utf-8');
        console.log('Added footer to ' + file);
    }
}
