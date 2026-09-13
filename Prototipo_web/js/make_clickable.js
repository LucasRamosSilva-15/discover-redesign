const fs = require('fs');
const path = require('path');

const dir = './Prototipo_web';
const files = ['teste.html', 'app-details.html', 'settings.html', 'updates.html', 'installed.html', 'about.html', 'category.html'];

for (const filename of files) {
    const file = path.join(dir, filename);
    if (!fs.existsSync(file)) continue;
    let content = fs.readFileSync(file, 'utf-8');
    
    // Add onclick and cursor-pointer to all app cards
    // The class string might vary slightly. Let's target: `class="group bg-white rounded-xl p-4 `
    // Replace: <div class="group bg-white rounded-xl p-4 
    // With: <div onclick="window.location.href='app-details.html'" class="group bg-white rounded-xl p-4 cursor-pointer 
    // (Only if it doesn't already have it)
    if (!content.includes("onclick=\"window.location.href='app-details.html'\"")) {
        content = content.replace(/<div class="group bg-white rounded-xl p-4 /g, `<div onclick="window.location.href='app-details.html'" class="group bg-white rounded-xl p-4 cursor-pointer `);
    }
    
    // Stop propagation on buttons inside the cards so clicking "Instalar" or the trash can doesn't navigate
    content = content.replace(/<button class="shrink-0 ml-3 /g, `<button onclick="event.stopPropagation();" class="shrink-0 ml-3 `);
    
    // In installed.html or updates.html there might be different buttons.
    // E.g., trash icon button: `<button class="p-2 text-slate-400 hover:text-rose-500`
    content = content.replace(/<button class="p-2 text-slate-400 hover:text-rose-500/g, `<button onclick="event.stopPropagation();" class="p-2 text-slate-400 hover:text-rose-500`);
    
    // Update button in updates.html: `<button class="shrink-0 ml-4 px-3 py-1.5 `
    content = content.replace(/<button class="shrink-0 ml-4 px-3 py-1.5 /g, `<button onclick="event.stopPropagation();" class="shrink-0 ml-4 px-3 py-1.5 `);
    
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Made apps clickable in ' + file);
}
