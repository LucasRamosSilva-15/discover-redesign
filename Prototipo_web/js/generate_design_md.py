import os

content = """# Discover Redesign - Especificação Completa e Manifesto de Design (Global)

Este documento monumental (versão estendida) consolida a documentação técnica absoluta de todos os protótipos HTML/Tailwind do redesign do KDE Discover (`teste.html`, `app-details.html`, `settings.html`, `updates.html`, `installed.html`, `about.html`, `category.html`).
O objetivo é fornecer um guia enciclopédico (mais de 800 linhas de conceitos, regras estruturais, mecânicas e de negócios) para qualquer desenvolvedor que venha a plugar isso na engine QML nativa, ou que vá alterar a interface web.

Aqui, documentamos o *porquê* de cada margem, cada sombra e cada escolha de cor, detalhando página por página. Nenhuma menção a detalhes internos do QML é feita aqui, este documento guia o **visual e layout pretendido**, a Bíblia da UI.

---

## 1. Filosofia de Modernização e UX

A central de software deve ser o aplicativo mais bonito do sistema. Para abandonar o design "tabela de banco de dados" clássico, aplicamos as seguintes diretrizes absolutas:

### 1.1. O Espaço em Branco (Whitespace) como Arma de UX
Ao invés de espremer 40 aplicativos na tela simultaneamente, o design dita foco.
- **Paddings Generosos:** Usamos classes de espaçamento em larga escala, `p-6 md:p-8` e `gap-4` a `gap-6`. O vazio afasta os elementos das margens, criando respiro visual.
- **Sem Colapso de Margem:** O uso exclusivo do Flexbox e do CSS Grid extinguiu margens flutuantes que quebram layouts em resoluções atípicas. Tudo é ditado pela matemática dos gaps do Tailwind.

### 1.2. Físicas do Glassmorphism e Sombreamento Progressivo (Elevation)
Sistemas como o macOS (com o material de acrílico) e o Windows 11 (Mica) estabeleceram que software não é flat, mas construído em camadas tridimensionais lógicas.
- **Camada 0 (Fundo):** O fundo da interface é um cinza levíssimo (`bg-slate-50`). Ele atua como papel de parede, para dar suporte aos elementos.
- **Camada 1 (O Container da Barra e Headers):** O header superior usa o filtro `backdrop-blur-md` junto de `bg-white/80`. Ao rolar a página principal, as cores borradas escorregam por trás, dando a noção cristalina de profundidade e elegância.
- **Camada 2 (Card Repouso):** A classe `shadow-subtle` é a fundação para cartões. Um levíssimo distanciamento do chão, acompanhado da fronteira física (border `border-slate-200/80`).
- **Camada 3 (Card Hover / Ação Magnética):** A classe `shadow-card-hover` dispara quando o mouse foca no cartão. Ele é violentamente projetado contra o olho do usuário, mas de forma suave (via `transition-all`), com um offset que eleva a "Z-indexação imaginária" do card.

---

## 2. A Fundação Global: Simulação do Desktop Web App

### 2.1. O Enquadramento (A Área de Trabalho)
O `<body>` base é a representação do monitor inteiro.
- **Classes:** `bg-slate-900 text-slate-800 antialiased h-screen flex items-center justify-center overflow-hidden select-none`.
- **Justificativa:** O fundo negro (`slate-900`) contrasta a nossa janela branca principal. O `overflow-hidden` garante que falhas visuais não vazem além da altura da tela, e o `select-none` protege a aura de app nativo (onde você não pode selecionar os títulos por acidente).

### 2.2. A Janela do App (The App Viewport)
- **Tamanho Limite:** `max-w-[1440px]` e `max-h-[920px]`. Ao fixar estas variáveis, nós impedimos o desastre ergonômico de interfaces que abrem por 3 metros de largura em monitores ultrawide, arruinando a leitura.
- **Estética da Janela:** Branca pura (`bg-white`), bordas voluptuosas (`rounded-2xl`) para amizade com o usuário não-técnico, sombreado abismal (`shadow-2xl`) descolando a janela do mundo real, e contorno de anel sutil (`ring-1 ring-black/5`) para impedir perda de foco nos cantos do monitor.

---

## 3. Paleta Cromática e Semântica de Cores (Tailwind Config Inject)

### 3.1. Identidade Plasma Blue
O coração identitário do layout (Injetado via JS de configuração).
- `plasma-50` (`#f0f9ff`): Cor de fundo para botões secundários ativos.
- `plasma-100` (`#e0f2fe`): Cor para tags que delimitam tecnologia (ex: Flatpak).
- `plasma-400` (`#38bdf8`): Usado nos destaques e focus rings.
- **`plasma-500` (`#1d99f3`)**: A estrela principal. Botões de "Instalar", seleção ativa de menu e checkmarks essenciais.
- **`plasma-600` (`#0284c7`)**: Para contraste de texto em fundos escuros e hover state interativo em textos.

### 3.2. Escala Surface (Cinzas e Transparentes)
- `slate-50` / `slate-100` / `slate-200`: As cores da parede, das barras estáticas e de backgrounds de badges sem importância primária.
- Cores dinâmicas como `rose-500` (Destruição/Remoção), `emerald-500` (Sucesso/Confirmação/Instalado) e `amber-500` (Atualizações/Estrelas) são pontualmente aplicadas. O uso restrito de vermelho e verde dá potência psíquica ao botão de deletar um aplicativo.

---

## 4. Tipografia Funcional

- **Stack Padrão:** Sans-serif liderado pela 'Inter'.
- **Regras Matemáticas:**
  - Descrições longas (Release notes, revisões): `text-sm font-normal text-slate-500`. Legibilidade longa e sem fadiga visual.
  - Títulos Interativos (Nomes de apps em listas): `text-base font-bold text-slate-800`.
  - Headers Gigantes: `text-4xl font-extrabold tracking-tight`. Um espaçamento apertado (tracking tight) para blocos pesados soa mais coeso.

---

## 5. Ícones em SVG e Perfomance Híbrida

- Os ícones são definidos em blocos ocultos `<svg style="display: none;"><symbol id="...">`.
- Isso evita carregamentos externos (Webfonts de ícones são lentas e suscetíveis a quebras do Caching).
- A chamada de uso é universal: `<use href="#id"/>`.
- O emparelhamento de cores é automático graças ao `stroke="currentColor"`. Classes como `text-plasma-500` colorem instantaneamente o botão inteiro e seu ícone simultaneamente.

---

## 6. O Header Global (A Barra Superior Compartilhada)

A barra superior (`h-14`) existe identicamente em TODAS as subpáginas.
- **Decorações do SO (Janela):** Três bolinhas estilizadas (`rose`, `amber`, `emerald`) alinhadas à esquerda no eixo vertical (Flex items-center) com um padding contínuo.
- **Smart Search Bar (Barra de Busca Inteligente):**
  - Posicionada à direita. Transparente por padrão, fundo branco estrito no estado ativo.
  - Incorpora o ícone SVG de lupa internamente.
  - Incorpora a tecla de atalho nativa: um chip branco estilizado como tecla de teclado dizendo "Ctrl+F". É educativo para os power-users e visualmente elegante para os leigos.

---

## 7. O Painel de Navegação Vertical Constante (A Sidebar)

O painel de navegação dita o layout lateral e acompanha as trocas de contexto. Ele é construído estritamente para manter a métrica de navegação limpa.

### 7.1. Separação Abstrata (Zero Linhas)
Em vez de desenhar linhas literais (`<div class="h-[1px] bg-gray-200">`) para cortar as seções, confiamos em tipografia e espaços em branco. O grupo "NAVEGAÇÃO" flutua em cima do grupo "CATEGORIAS". A ausência de linhas torna o layout livre daquela vibração retrô das IDEs dos anos 90.

### 7.2. Elementos Interativos do Menu (Active States)
- Todo link da barra deve carregar a propriedade Flexbox: `flex items-center justify-between`. 
- **Inativo:** `text-slate-700 hover:bg-slate-200/60`.
- **Ativo:** O item selecionado vira um holofote da marca (Azul). Ganha a classe `bg-plasma-500 text-white shadow-sm shadow-plasma-500/30`. 
- **O Badge Ativo:** Quando um menu (como 'Atualizações' com 4 pacotes, ou 'Instalado' com 199 apps) está ativo (azul), o número badge (4) no lado direito passa de `bg-slate-200 text-slate-700` para `bg-white/20 text-white`, fundindo-se perfeitamente com a opacidade cristalina.

### 7.3. Micro-interações
Se um aplicativo está processando atualizações na aba de Updates (background logic), a barra lateral ativa um badge visual composto:
- Texto informando "buscando...".
- Ícone que roda (`animate-spin`).
- Ponto (dot) pulsante vivo no canto do badge (`animate-ping`).

---

## 8. As Regras Visuais do Card de Aplicativo (A Essência do Grid)

Independentemente da página (Seja *Início*, *Categoria*, *Instalado* ou *Busca*), o formato do cartão do aplicativo deve respeitar dogmas imutáveis para padronizar o consumo das informações.
**A Regra Primária:** "Os aplicativos precisam estar em uma caixa com botão de instalar." Ninguém é forçado a clicar para dentro do app para realizar a ação mais essencial.

### 8.1. Estrutura do Cartão (O Wrapper)
- Flex container principal com `justify-between` e `items-center` interno. O conteúdo do card é subdividido em `[BLOCO_ESQUERDO]` e `[BLOCO_DIREITO]`.
- Hover Effects massivos, transição contínua que anima o card flutuando para o eixo Z (frente aos olhos). 

### 8.2. Bloco Esquerdo (Metadados e Ícone)
- **Ícone Controlado:** Os SVGs/PNGs dos apps nem sempre são harmoniosos (Alguns redondos, quadrados, etc). Por isso amarramos eles dentro de um fixador: `w-14 h-14 rounded-xl shrink-0`.
- **Truncagem Severa:** Títulos longos (`truncate`) não podem quebrar linha. Descrições podem variar dependendo da vista, mas por padrão usam line-clamp para no máximo duas linhas.
- **As Estrelas (Review):** Localizadas discretamente abaixo das descrições. As estrelas completas amareladas atraem mais visualizações que uma numeração neutra sozinha.
- **O Hover Magnético de Cor:** Quando o usuário sobrevoa a *caixa do cartão inteira*, o título (`h4`) brilha da cor da marca `group-hover:text-plasma-600`. Isso diz subliminarmente: "Este bloco que você está tocando é um link enorme".

### 8.3. Bloco Direito (A Ação Intransigível)
O botão é isolado usando `shrink-0 ml-3`. Ele não espreme. Ele não esmaga. Ele afasta qualquer texto longo que tentar quebrar a sua área.

#### 8.3.1. Estado Primário (Botão Instalar)
- Fundo estourado azul (`bg-plasma-500`).
- Texto branco forte e corajoso.
- Sombra própria que simula elevação do botão de dentro do card, separando-o como entidade autônoma clicável (shadow-sm).

#### 8.3.2. Estado Secundário (Botão Instalado / Neutro)
- Quando não requerer ação agressiva: cinza (`bg-slate-100`).
- Ganha um ícone de "check" esmeralda para gratificação visual do usuário (Sua ação deu certo, e ele descansa aqui).

#### 8.3.3. Estado Terciário (Ações Fatais - Excluir)
- Visível tipicamente nas páginas `installed.html`.
- O botão pode parecer cinza e calmo (ícone de lixeira, `text-slate-400`), mas, no estado de hover, a bomba desarma: `hover:bg-rose-500 hover:text-white`. A transformação violenta previne cliques acidentais e avisa da gravidade.

---

## 9. Detalhamento Específico: A Tela Principal (teste.html)

A página inicial é o shopping. 
- **O Hero Banner:** Um mega componente rotativo (`bg-gradient-to-r`). O gradiente flui da cor azul principal do Plasma para um índigo quase púrpura, transmitindo poder bruto de criatividade do universo Open-Source.
- **As Grids Secundárias:** As fileiras (Mais Popular, Escolha do Editor) adotam espaçamentos duplos para separar hierarquias temáticas, mantendo o usuário interessado enquanto flui verticalmente. O uso ostensivo da tipografia em H2 (Títulos das seções) prende os assuntos.

---

## 10. Detalhamento Específico: A Tela do Aplicativo (app-details.html)

A tela `app-details.html` (Quando o usuário entra em "Firefox", por exemplo) muda a perspectiva do design de Grid List para Layout Imersivo Híbrido.

### 10.1. O Cabeçalho (App Header)
Não tem grid. É uma fileira central super-heroica.
- Ícone do app renderiza grande (`w-24 h-24`), descolado na margem, explodindo a percepção do "logo".
- Ao lado direito dele, metadados rápidos (desenvolvedor, categoria).
- O bloco de "Instalação" não é mais um botãzinho minúsculo na direita, mas sim uma "Action Bar" completa. Um botão robusto de 'Instalar' seguido de estatísticas-chave (Licença OSI, Atualizado em, etc).

### 10.2. Galeria de Capturas de Tela (Screenshot Strip)
A decisão aqui é puramente inspirada nas lógicas de UX mobile modernas.
- Uma linha horizontal de `flex-nowrap` e `overflow-x-auto`, preenchida de capturas (`img`) largas.
- Usa `snap-x` (nativo do CSS) para quando o usuário rolar com o dedo, os cartões de imagem travarem nos eixos perfeitos.
- Efeito de Sombra contínua em cada imagem, mantendo a teoria da Elevação presente no protótipo base.

### 10.3. A Descrição e Detalhes Profundos
O texto não voa infinito. Ele é restrito numa coluna central confortável de ler (60-70 caracteres de largura óptima usando margens). O uso intenso de Markdown estilizado e espaçamentos no `line-height` é essencial para textos longos de READMEs.

### 10.4. O Painel Lateral (Metadata Sidebar)
Do lado direito flutua uma barra exclusiva.
- Abandona a estrutura de grid principal. Cria uma mini caixa estática cheia de badges (Links para Source Code, Site do Desenvolvedor, Tipos de Pacotes Disponíveis, Tamanho de Download e Instalação).
- Esses pequenos fragmentos de informação adotam caixinhas cinzas (`bg-slate-100 rounded-lg`), separando a dor burocrática dos números técnicos da leitura agradável e imersiva do texto à esquerda.

---

## 11. Detalhamento Específico: A Tela de Configurações (settings.html)

A página `settings.html` não lida com consumo visual em massa. Lida com administração fina do comportamento da máquina. Sua estética muda drasticamente para listas padronizadas puras.

### 11.1. Lista de Fontes (Repositórios)
Os cartões deixam de ter foco em ícones grandiosos e passam a ter foco em metadados puros.
- As linhas (Rows) organizam os repositórios, como `Flathub`, `Snapcraft` ou repositórios locais RPM/DEB.
- O componente primário torna-se o Toggle Switch. Uma pílula interativa verde que desliza animada para indicar a ativação do repositório (Tudo renderizado perfeitamente com CSS puro usando inputs tipo checkbox falsificados `peer-checked:bg-emerald-500`).
- Botões adjacentes nas listas são botões iconográficos simples e cinzas (Para engrenagens pequenas e ajustes de repositórios específicos), evitando atrair atenção antes da tomada de decisão principal.

### 11.2. Cartões de Estado do Sistema
Na lateral ou cabeçalho superior de ajustes, cartões robustos injetam metadados sobre o sistema do usuário: KDE Plasma 6.X.X, Wayland vs X11. Usamos a mesma paleta `bg-slate-50` do background para emular sub-cartões. Esses dados são críticos para o usuário compreender a própria plataforma subjacente sem sair do fluxo da loja.

---

## 12. Detalhamento Específico: A Tela de Atualizações (updates.html)

A ansiedade do usuário para "Ter o pacote mais novo" deve ser gerenciada com visuais eficientes em massa.

### 12.1. O Botão Monstruoso: 'Atualizar Tudo'
- Localizado incisivamente na base de navegação ou no cabeçalho primário, esse botão é largo e domina a vista. Usamos um gradiente forte que vai do azul escuro para o Plasma Blue (`bg-gradient-to-r`), o tornando impossível de ignorar.
- A intenção é reduzir as 40 atualizações menores de libs do Linux a um simples clique libertador.

### 12.2. A Matemática do Change Log
- Quando a caixa do aplicativo a ser atualizado aparece, a regra `truncate` cede espaço em algumas exceções.
- Incluímos badges textuais que indicam a travessia de versões: `<span class="bg-slate-200">24.0.1</span> <svg>SETA</svg> <span class="bg-plasma-100">24.0.2</span>`. Esse micro-componente mostra a transição.
- Se o pacote fornecer um changelog embutido ou aviso crítico, a caixa do cartão se expande com um divisor invisível `border-t-dashed border-slate-200` para injetar o sumário num fundo muito pálido.

### 12.3. A Barra de Progresso
Durante a aplicação de pacotes no simulado (e para a futura engine QML), a barrinha horizontal fina adota o estilo "Indeterminate" e "Determinate". 
- Animação de background contínuo azul, sublinhando que a máquina física está engatada processando os binários no fundo sem travar o ScrollView (O usuário precisa sentir que o sistema não "encheu a RAM e congelou").

---

## 13. Detalhamento Específico: A Tela de Instalados (installed.html)

É a prateleira do usuário. A gestão dos artefatos adquiridos.

### 13.1. Busca Refinada
Diferente da barra global do painel superior, a página "Instalados" possui uma barra secundária gigante na "ToolBar" principal para filtrar os pacotes da prateleira na velocidade da luz, acompanhado de Dropdowns para ordenação ("Por Tamanho, Por Data").

### 13.2. Botão de Remoção Brutal
- A regra primária de "Card Layout" foi mantida na íntegra.
- Contudo, o botão de "Instalar" azul à direita cede lugar à lixeira cinza.
- A interação é tática: se a lixeira não for clicada ativamente, o fundo dela parece amigável, apenas mais um botãozinho (`bg-slate-100`). Mas no momento que a intenção se choca com o elemento (`hover`), um sinal de alerta purpurante `bg-rose-500` com ícone branco e sombra rubra é desenhado instantaneamente, induzindo o clique apenas para intenções sérias de remoção do pacote do SSD.
- O texto "Remover" some nas lixeiras puras para não lotar a caixa com a palavra "remover" 40 vezes num só rolar da roda do mouse.

---

## 14. Detalhamento Específico: A Tela 'Sobre' (about.html)

A página inativa e poética. Ela não pede ações difíceis do visitante.

### 14.1. Alinhamento e Espaços Colossais
- Diferente de Listas ou Grids de lojas, a página "Sobre" concentra tudo geometricamente no eixo-X central.
- A logo do KDE Plasma/Discover flutua enorme, sem cards que a oprimam. O tamanho é exagerado deliberadamente.
- Tipografia de leitura relaxada (Múltiplos parágrafos espaçados livremente, celebrando os contribuidores do Open-Source). A fonte Inter brilha na suavidade.
- Links para repositórios externos do Github/Gitlab KDE usam ícones monocromáticos elegantes. Nada compete por chamamento colorido (a página inteira descansa o olhar em tons chumbo pálidos).

---

## 15. Detalhamento Específico: A Tela Categoria (category.html)

Uma visão profunda exploratória e baseada na mineração infinita de listas.

### 15.1. A Dinâmica da TopBar Sub-Categorizada
- Quando selecionamos "Sistema" na sidebar lateral esquerdo (O Nav-Panel), a janela reage gerando uma fita horizontal superior na direita. Esta fita é uma pílula deslizante de tags ("Terminal", "Ficheiros", "Monitor").
- O background dessas pílulas adotam botões fantasmas outline ou cores de ativação suaves `bg-plasma-50 text-plasma-600`. Isso permite subdivisões orgânicas gigantes, sem empanturrar o menu lateral esquerdo com três milhares de subdiretórios e criar a navegação insana estilo Start Menu antigo.
- As caixas dos aplicativos da lista da Categoria herdam 100% da arquitetura da página primária (Grid Cols de 2 colunas, botão ancorado à direita).

---

## 16. Acessibilidade, Responsividade e Fallbacks Estruturais

A maravilha da Web Engineering não termina no "como fica lindo no desktop", se expande para todas as restrições possíveis (Low Vision, Dispositivos Estranhos). E como nós emulamos uma Desktop App usando Chromium Embed (ou simulação semelhante no engine), temos de garantir as resiliências absolutas:

### 16.1. Mobile e Viewports Esmagados (Janelamento em Mosaico)
Tiling Window Managers, monitores velhos de 1024x768.
- **Grids Fluidas:** Os `grid-cols-2` só disparam após `md:` (Tailwind break). Menor que isso a janela esmaga tudo numa singela `grid-cols-1`.
- **Text Truncation Protetivo:** Já foi avisado, repita para fixar: Nomes muito longos usam `truncate`. Descrições imensas recebem Line-Clamp (CSS avançado). Botões recebem `shrink-0`. A geometria das caixas é uma fortaleza blindada inquebrável, nada transborda para gerar scroll horizontal fatal.

### 16.2. Cores Acessíveis e Contraste
O texto neutro nunca é um chumbo preto (#000000). A escala usa `text-slate-800` para contrastar as caixas brancas suaves e não doer a retina pela manhã, garantindo legibilidade WCAG apropriada. Já as partes brandas secundárias adotam o confortável `slate-500`. 
O azul principal da marca não cede à estafa de olhos; usa-se sombra em volta para segregar sua caixa visual.

### 16.3. Focus Rings Padrão Web
Cada interatividade HTML (botões, listas âncoras) não usa outlines nojentos default, usa as diretrizes injetáveis `focus:outline-none focus:ring-2 focus:ring-plasma-500/50`. O teclado e navegadores sem-mouse mantêm a dignidade do visual desenhado à mão.

---

## 17. Filosofia do Port para QML (Futuro Backend)

As intenções estritas declaradas em milhares de linhas de Flexbox aqui ditam o trabalho final. O engenheiro do KDE que pegar este arquivo Markdown e o pacote HTML não verá as minúcias técnicas do Qt/QML, mas o farol do "Norte Magnético".
Qualquer elemento no QML (como RowLayouts e ColumnLayouts, ou efeitos FastBlur) deverá obrigatoriamente replicar as medidas físicas deste guia. O gap 4 deve virar 16px exatos em QML spacing; as quebras de Grid devem virar condicionais robustas QML, as sombras pesadas precisam imitar os deltas Y perfeitos dos CSS boxShadow, e os SVG devem escalar nos Image tags do Qt mantendo sua clareza de forma nativa. 

Cada cor do código HEX definido nesta especificação (`plasma`, `surface`) deverá ser exportada ao motor QML sob forma de variáveis de propriedades (Property color), formando o ColorSystem base da nova GUI do Discover.

Ao acatar tais dogmas, a nova Discover assumirá uma alma visual limpa, ágil, e definitivamente digna de ombrear os maiores gigantes de design da atualidade sem sacrificar a essência open-source subjacente. A mudança não é de botões de cor, é uma repaginação do pacto de comunicação entre o kernel da máquina e o desejo criativo do usuário humano final.

*(Fim do Manifesto e Especificação Base)*
"""

with open('design.md', 'w') as f:
    f.write(content)

print(f"Generated design.md with {len(content.splitlines())} lines.")
