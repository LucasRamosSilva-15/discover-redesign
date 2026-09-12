const fs = require('fs');

const svgCategories = `
        <!-- Category Icons -->
        <symbol id="cat-todos" viewBox="0 0 24 24"><path d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-acess" viewBox="0 0 24 24"><path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-ciencia" viewBox="0 0 24 24"><path d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-dev" viewBox="0 0 24 24"><path d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-edu" viewBox="0 0 24 24"><path d="M12 14l9-5-9-5-9 5 9 5z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-office" viewBox="0 0 24 24"><path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-gfx" viewBox="0 0 24 24"><path d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-web" viewBox="0 0 24 24"><path d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-games" viewBox="0 0 24 24"><path d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-media" viewBox="0 0 24 24"><path d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-sys" viewBox="0 0 24 24"><path d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-utils" viewBox="0 0 24 24"><path d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
        <symbol id="cat-drv" viewBox="0 0 24 24"><path d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
    </svg>`;

const htmlSidebarCategories = `
                    <div class="space-y-1" id="nav-group-categories">
                        <div class="px-3 pb-1 text-[11px] font-bold uppercase tracking-wider text-slate-400">Categorias</div>
                    </div>`;

const jsCategories = `
        renderNav('nav-group-categories', [
            { icon: 'cat-todos', label: 'Todos os aplicativos' },
            { icon: 'cat-acess', label: 'Acessibilidade' },
            { icon: 'cat-ciencia', label: 'Ciências e matemática', hasSubmenu: true },
            { icon: 'cat-dev', label: 'Desenvolvimento', hasSubmenu: true },
            { icon: 'cat-edu', label: 'Educação' },
            { icon: 'cat-office', label: 'Escritório' },
            { icon: 'cat-gfx', label: 'Gráficos', hasSubmenu: true },
            { icon: 'cat-web', label: 'Internet' },
            { icon: 'cat-games', label: 'Jogos' },
            { icon: 'cat-media', label: 'Multimídia', hasSubmenu: true },
            { icon: 'cat-sys', label: 'Sistema' },
            { icon: 'cat-utils', label: 'Utilitários' },
            { icon: 'cat-drv', label: 'Drivers de hardware' }
        ]);`;

const files = ['app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const file of files) {
    let content = fs.readFileSync(file, 'utf-8');
    
    // 1. Clean up category.html's existing SVG and HTML to avoid duplicates
    if (file === 'category.html') {
        content = content.replace(/<symbol id="cat-sys"[\s\S]*?<\/symbol>/, '');
        content = content.replace(/<symbol id="cat-todos"[\s\S]*?<\/symbol>/, '');
        content = content.replace(/<div class="h-\[1px\] bg-slate-200"><\/div>\s*<div class="space-y-1" id="nav-group-categories">\s*<!-- Rendered by JS -->\s*<\/div>/, '');
        // Remove the existing JS call
        content = content.replace(/renderNav\('nav-group-categories'[\s\S]*?\]\);/, '');
    }

    // Insert SVG Categories before </svg>
    if (!content.includes('id="cat-todos"')) {
        content = content.replace('</svg>', svgCategories.trim() + '\n    </svg>');
    }

    // Insert Sidebar HTML after nav-group-main
    if (!content.includes('id="nav-group-categories"')) {
        content = content.replace(
            /id="nav-group-main">[\s\S]*?<\/div>/,
            match => match + '\n' + htmlSidebarCategories
        );
    }

    // Insert JS call
    if (!content.includes("renderNav('nav-group-categories'")) {
        // Find the place after the first renderNav call
        content = content.replace(
            /(renderNav\('nav-group-main', \[[\s\S]*?\]\);)/,
            match => match + '\n\n' + jsCategories.trim()
        );
    }

    // Note: If category.html, set 'Sistema' to active: true
    if (file === 'category.html') {
        content = content.replace(
            /{ icon: 'cat-sys', label: 'Sistema' }/,
            "{ icon: 'cat-sys', label: 'Sistema', active: true }"
        );
    }

    fs.writeFileSync(file, content, 'utf-8');
    console.log('Updated ' + file);
}
