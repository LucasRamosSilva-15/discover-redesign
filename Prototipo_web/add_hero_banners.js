const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';

const pages = [
    {
        file: 'installed.html',
        title: 'Aplicativos Instalados',
        subtitle: 'Gerencie os pacotes e softwares presentes no seu sistema.',
        icon: 'nav-instalado',
        gradient: 'from-emerald-500 to-teal-700'
    },
    {
        file: 'updates.html',
        title: 'Atualizações',
        subtitle: 'Mantenha seu sistema seguro e com as últimas novidades.',
        icon: 'nav-atualizacoes',
        gradient: 'from-amber-500 to-orange-600'
    },
    {
        file: 'settings.html',
        title: 'Configurações',
        subtitle: 'Gerencie fontes de software, repositórios e preferências.',
        icon: 'nav-config',
        gradient: 'from-slate-600 to-gray-800'
    },
    {
        file: 'about.html',
        title: 'Sobre o Discover',
        subtitle: 'Central de software do ambiente KDE Plasma.',
        icon: 'nav-sobre',
        gradient: 'from-plasma-500 to-indigo-700'
    }
];

const generateHero = (p) => `
                <!-- Hero Header -->
                <div class="relative overflow-hidden rounded-2xl bg-gradient-to-r ${p.gradient} text-white p-6 shadow-lg shrink-0 mb-6">
                    <div class="absolute -right-4 -bottom-8 opacity-10 pointer-events-none">
                        <svg class="w-64 h-64 text-white" fill="currentColor" viewBox="0 0 24 24"><use href="#${p.icon}" /></svg>
                    </div>
                    <div class="relative z-10 max-w-xl flex items-center gap-5">
                        <div class="w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-md flex items-center justify-center shrink-0 border border-white/20 shadow-inner">
                            <svg class="w-8 h-8 text-white"><use href="#${p.icon}"/></svg>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold tracking-tight text-white mb-1">${p.title}</h2>
                            <p class="text-white/80 text-sm leading-relaxed">${p.subtitle}</p>
                        </div>
                    </div>
                </div>
`;

pages.forEach(p => {
    const filePath = path.join(dir, p.file);
    if (!fs.existsSync(filePath)) return;
    
    let content = fs.readFileSync(filePath, 'utf-8');
    
    // Most of these files have a simple header like:
    // <div class="space-y-1">
    //     <h2 class="text-2xl font-bold tracking-tight text-slate-800">Title</h2>
    //     <p class="text-slate-500 text-sm">Subtitle</p>
    // </div>
    // Let's replace it with the new Hero banner
    
    const simpleHeaderRegex = /<div class="space-y-1">\s*<h2 class="text-2xl font-bold tracking-tight text-slate-800">.*?<\/h2>\s*<p class="text-slate-500 text-sm">.*?<\/p>\s*<\/div>/;
    
    // In about.html, it might be different:
    // <div class="flex flex-col items-center justify-center h-full space-y-6 text-center">
    //     <div class="w-24 h-24 bg-plasma-500 rounded-3xl ...">
    const aboutRegex = /<div class="flex flex-col items-center justify-center h-full space-y-6 text-center">[\s\S]*?(?=<\/main>)/;

    if (p.file === 'about.html') {
        // If about is completely different, we might just replace everything inside main
        // Let's first check if we can just wrap the about content, or replace it entirely.
        // The user said "caixinha parecida", so they want the hero banner.
        // Let's replace the top of about.html, but keep the rest if it exists.
        // Actually, about.html is just a simple logo and text. The hero banner replaces it well.
        content = content.replace(aboutRegex, generateHero(p));
    } else {
        content = content.replace(simpleHeaderRegex, generateHero(p).trim());
    }
    
    fs.writeFileSync(filePath, content, 'utf-8');
    console.log('Added Hero banner to ' + p.file);
});
