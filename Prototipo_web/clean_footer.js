const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

const correctStructure = `</main>
        </div>

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
        </footer>
    </div>

    `;

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // We want to replace from </main> all the way down to either <script> or </body>
    // using a non-greedy match to find the first <script> or </body> after </main>
    content = content.replace(/<\/main>[\s\S]*?(?:(<!-- JS)|(<script>)|(<\/body>))/i, (match, p1, p2, p3) => {
        // p1 is "<!-- JS", p2 is "<script>", p3 is "</body>"
        const nextTag = p1 || p2 || p3;
        return correctStructure + nextTag;
    });

    fs.writeFileSync(file, content, 'utf-8');
    console.log('Cleaned footer in ' + file);
}
