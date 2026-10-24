<defs>
 <filter id="paper" x="-15%" y="-15%" width="130%" height="130%">
  <feTurbulence id="pt" type="fractalNoise" baseFrequency="0.045" numOctaves="2" seed="3" result="n"/>
  <feDisplacementMap in="SourceGraphic" in2="n" scale="3.2" result="d"/>
  <feMorphology in="d" operator="dilate" radius="2.2" result="m"/>
  <feFlood flood-color="#F3E9D2"/><feComposite in2="m" operator="in" result="o"/>
  <feMerge result="s"><feMergeNode in="o"/><feMergeNode in="d"/></feMerge>
  <feDropShadow in="s" dx="3" dy="4" stdDeviation="0" flood-color="#000" flood-opacity=".32"/>
 </filter>
 <filter id="paperNoOutline" x="-15%" y="-15%" width="130%" height="130%">
  <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves="2" seed="8" result="n"/>
  <feDisplacementMap in="SourceGraphic" in2="n" scale="3" result="d"/>
  <feDropShadow in="d" dx="3" dy="4" stdDeviation="0" flood-color="#000" flood-opacity=".3"/>
 </filter>
 <filter id="grain" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" seed="5"/><feColorMatrix type="saturate" values="0"/></filter>
 <linearGradient id="skyG" gradientUnits="userSpaceOnUse" x1="0" y1="-1600" x2="0" y2="620">
  <stop offset="0" stop-color="#05070d"/><stop offset=".42" stop-color="#121a30"/><stop offset=".7" stop-color="#6d5d62"/><stop offset=".88" stop-color="#e2a766"/><stop offset="1" stop-color="#f4d6a0"/>
 </linearGradient>
 <radialGradient id="sun"><stop offset="0" stop-color="#fff2c6" stop-opacity=".95"/><stop offset="1" stop-color="#fff2c6" stop-opacity="0"/></radialGradient>
 <radialGradient id="vig" cx=".5" cy=".5" r=".75"><stop offset=".55" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".45"/></radialGradient>
 <linearGradient id="swp" x1="0" x2="1"><stop offset="0" stop-color="#ffd98a" stop-opacity="0"/><stop offset=".5" stop-color="#ffe3a0" stop-opacity=".55"/><stop offset="1" stop-color="#ffd98a" stop-opacity="0"/></linearGradient>
 <g id="eyeGlyph">
  <path d="M-30 0 Q0 -26 30 0 Q0 26 -30 0Z" fill="none" stroke="#C8452F" stroke-width="4" stroke-linejoin="round"/>
  <circle r="11" fill="#C8452F"/><circle cy="-2" r="3.6" fill="#F3E9D2"/><path d="M-2 0 L2 0 L3.6 8 L-3.6 8Z" fill="#F3E9D2"/>
 </g>
 <g id="eyeGlyphY">
  <path d="M-30 0 Q0 -26 30 0 Q0 26 -30 0Z" fill="none" stroke="#E0A526" stroke-width="4" stroke-linejoin="round"/>
  <circle r="11" fill="#E0A526"/><circle cy="-2" r="3.6" fill="#1F2A44"/><path d="M-2 0 L2 0 L3.6 8 L-3.6 8Z" fill="#1F2A44"/>
 </g>
 <g id="eyeGlyphN">
  <path d="M-30 0 Q0 -26 30 0 Q0 26 -30 0Z" fill="none" stroke="#1F2A44" stroke-width="4" stroke-linejoin="round"/>
  <circle r="11" fill="#1F2A44"/><circle cy="-2" r="3.6" fill="#F3E9D2"/><path d="M-2 0 L2 0 L3.6 8 L-3.6 8Z" fill="#F3E9D2"/>
 </g>
 <linearGradient id="loungeG" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#141A2E"/><stop offset="1" stop-color="#2d3558"/></linearGradient>
 <linearGradient id="marshG" gradientUnits="userSpaceOnUse" x1="0" y1="-300" x2="0" y2="700"><stop offset="0" stop-color="#0b1020"/><stop offset=".6" stop-color="#1e3a48"/><stop offset="1" stop-color="#4e7f7c"/></linearGradient>
 <linearGradient id="whG" gradientUnits="userSpaceOnUse" x1="0" y1="-200" x2="0" y2="900"><stop offset="0" stop-color="#0d1222"/><stop offset="1" stop-color="#26325a"/></linearGradient>
</defs>