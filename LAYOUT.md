# Table talk companion: layout definition

This is a companion web page for a 45-minute conference table talk. The audience opens it on their phones from a QR code. They follow the slides live, take a short maturity check, share ideas with the table, and leave feedback. The host opens the same page with `#host`, signs in, and gets a control view: move the slides, read the script, watch the room.

There are two modes. Audience mode is a mobile-first single column with a bottom tab bar. Host mode is the same frame with no tab bar and a stack of control cards. The whole app is one static `index.html` (vanilla HTML, CSS and JS, no build step). Supabase provides live sync of the current slide, storage of audience input, and host sign-in.

Live URL: https://douglasromao.github.io/ignite2026/ . Repo: https://github.com/douglasromao/ignite2026 .

## Screen map

| Screen | URL hash | Who sees it | Purpose |
|---|---|---|---|
| Home | none (empty hash) | Audience | Welcome, share box, two choice cards (follow the presentation, take the check) |
| Presentation | `#live` | Audience | One slide at a time, following the host or browsing freely, with reactions |
| My check | `#check` | Audience | Intro, 8 questions one at a time, result with contact form |
| Feedback | `#feedback` | Audience | Star rating and two optional text answers |
| Connect dialog | none (modal `<dialog>`) | Audience and host | QR code and link for staying in touch, opened from the header on every screen |
| Host sign-in | `#host` (not signed in) | Host | Email and password form |
| Host view | `#host` (signed in) | Host | Controls, script, notes, live pulse, shared items, feedback, jump list, join code |

Navigation:

- Audience navigation is the fixed bottom tab bar with four tabs: Home, Presentation, My check, Feedback. Each tab sets `location.hash`. Home sets an empty hash.
- Routing is hash based. `viewFromHash()` maps `#live`, `#check`, `#feedback` to their views, `#host` to the host view, and anything else to Home. A `hashchange` event re-renders the view and scrolls to the top.
- The browser back button works because every tab and choice card changes the hash.
- Switching between `#host` and any other hash reloads the page, because the two modes bind different handlers.
- Arrow keys, audience: in the Presentation view left and right press the previous and next slide buttons. In My check left presses Back (or Review answers) and right presses Next (or Start). Ignored while focus is in an `input`.
- Arrow keys, host: left and right go to the previous and next slide. Ignored while focus is in an `input` or `textarea`.
- The Feedback screen is also reachable from a "Give feedback" button on the last slide.

## Page frame

Top to bottom, inside a dark page with fixed glows behind it:

1. Header: a flex row, `gap: 10px`, items centred vertically, `padding` 16px top and bottom, 16px sides. Max width 720px, centred.
   - Pill with two parts: event code (paper chip) and table name.
   - Connect button: `.primary.fab`, icon plus the word "Connect". Opens the QR dialog.
   - Status label at the far right (`#status`, `margin-left: auto`, right aligned): "Live" with a pulsing coral dot in audience mode, "Host" in host mode, "Demo mode" when Supabase is not configured.
   - The pill and the Connect button are `flex: none; white-space: nowrap` so they never wrap.
2. Main column: `main`, max width 720px, centred, 16px side padding, no top padding. It holds four sections, only one visible at a time in audience mode: `#home`, `#slide`, `#feedback`, `#check` (all `.card`), plus `#host` (a plain container for the host cards).
3. Footer: centred, `padding: 0 16px 110px` (the 110px bottom padding keeps content clear of the fixed tab bar). Contents: a row of logos (`.brands`: flex, centred, `gap: 22px`, `margin-bottom: 12px`; each image 44px high, max width 130px, `object-fit: contain`; a wide wordmark can be set to 30px high) and one plain credit line in the `.note` style ("Hosted by" plus the host name and title). Logos are files in `logos/`. A logo that fails to load falls back to its `.png`, then removes itself.
4. Bottom navigation: `#tabs`, `position: fixed`, `bottom: 12px`, centred with `left: 50%` and `translateX(-50%)`, `width: min(94vw, 420px)`, `z-index: 5`. Hidden in host mode.
5. Reactions overlay: `#fx`, `position: fixed; inset: 0; overflow: hidden; pointer-events: none; z-index: 20`. It sits above everything, including the tab bar, and never takes taps.
6. Connect dialog: native `<dialog class="card qr">`, `width: min(92vw, 380px)`, centred, shown with `showModal()`. Backdrop `rgba(0, 0, 0, .6)` with `blur(4px)`. Tapping the backdrop closes it.

Page background: `body` uses `--ink`. A fixed `body::before` at `z-index: -1` paints three radial glows over `--ink` so the frosted panels have something to show through:

| Glow | Size | Position | Colour |
|---|---|---|---|
| 1 | 38rem by 28rem | 90% across, -5% down | `rgba(229, 65, 43, .42)` |
| 2 | 32rem by 26rem | -15% across, 55% down | `rgba(229, 65, 43, .26)` |
| 3 | 30rem by 22rem | 75% across, 105% down | `rgba(253, 251, 250, .12)` |

Each glow fades to transparent at 62%.

Z-order, lowest to highest: background glows (-1), page content (auto), tab bar (5), reactions overlay (20), open dialog (top layer, above all).

## Design tokens

The page is dark only (`color-scheme: dark`). All colours are CSS variables on `:root` except a few one-off values listed below.

### Colours

| Variable | Value | Used for |
|---|---|---|
| `--paper` | `#FDFBFA` | Text on dark, primary button face, share box background, ladder "on" cell |
| `--ink` | `#1A1714` | Page background, text on coral and on paper |
| `--soft` | `#B8AEA8` | Secondary text, labels, idle tab icons, lead paragraphs |
| `--coral` | `#E5412B` | Borders, chunky shadows, accent fills, progress dots, bar fills |
| `--coral-deep` | `#A52A19` | Declared, same value as `--fill-deep` |
| `--fill` | `#E5412B` | Solid coral surfaces: callout, highlighted phrase, active step, active tab |
| `--fill-deep` | `#A52A19` | Bottom edge of solid coral surfaces |
| `--coral-text` | `#E5412B` | Coral used as text colour (labels, numbers, accordion plus) |
| `--glass` | `rgba(38, 32, 28, .55)` | Frosted card background |
| `--hair` | `rgba(253, 251, 250, .18)` | Hairlines, idle borders, idle bars and dots |

`--fill`, `--fill-deep` and `--coral-text` equal the coral values today. They exist so a theme can change surface fills and text colour separately without touching `--coral`.

One-off colours:

| Value | Used for |
|---|---|
| `#ff9c8c` | Error text on dark, the late clock and its border |
| `#B3261E` | Error text inside the share box (paper background) |
| `#FFD43B`, `#FFE98A`, `#E8A200` | Share box light bulb: base fill, glow fill, stroke colour |
| `rgba(38, 32, 28, .72)` | Tab bar background |
| `rgba(38, 32, 28, .92)` | Dialog background |
| `rgba(0, 0, 0, .28)` | Text input background on dark |
| `#fff` | Input background in the share box, QR code background |
| `rgba(229, 65, 43, .2)` | Selected option background, kind chips on the Home card |
| `rgba(229, 65, 43, .18)` | Choice card hover background |
| `rgba(253, 251, 250, .06)` | Default button background |
| `rgba(253, 251, 250, .05)` | Choice card background |

### Typography

Fonts load from Google Fonts: Inter 400, 600, 700; Poppins 700, 800; IBM Plex Mono 600.

| Family | Variable | Used for |
|---|---|---|
| Inter | none (body font) | Body text, inputs, option text |
| Poppins | `--display` | Headings, buttons, titles, numbers, pill value, tab labels |
| IBM Plex Mono | `--mono` | `.label` (small uppercase tags), pill key |

Body: `17px/1.5`. Key sizes:

| Element | Font |
|---|---|
| `h1` | Poppins 800, `clamp(28px, 7.2vw, 44px)/1.12`, letter spacing `-.035em`, margin `20px 0 14px` |
| `h2` | Poppins 700, `20px/1.25`, margin `0 0 10px` |
| `.lead` | 18px, `--soft` |
| `.note` | 14px, `--soft` |
| `.label` | Plex Mono 600, `12px/1.2`, letter spacing `.12em`, uppercase, `--soft` |
| Pill key | Plex Mono 600, 12px, uppercase |
| Pill value | Poppins 700, 14px |
| Callout text | Poppins 700, `19px/1.3` |
| `.primary` | Poppins 700, 17px |
| Tab label | Poppins 700, 10px |
| Step button | Poppins 700, `11.5px/1.2`; number Poppins 800, 22px |
| Host "Say" text | 19px, line height 1.45 |
| Host clock | Poppins 800, 22px, tabular numerals |
| Star glyph | 34px |
| Reaction emoji (button) | 22px; floating: 34px |
| Table cells | 15px; first column Poppins 700, no wrap |

### Shape

| Token | Value | Where |
|---|---|---|
| Card radius | 18px | `.card`, tab bar |
| Callout, share box, choice card, home box | 14px | `.fill`, `.sharebox`, `.pick`, `.home`, `.feeds` |
| Button, input, option, step, star | 12px | Default button, inputs, step buttons, star cells |
| Pill radius | 10px | `.pill`, `.fab` |
| Small radius | 8px | `.ladder span`, `.srcs span`, `.pick > b` |
| Chip radius | 99px | Kind chips, home kind chips |
| Round | 50% | Reaction buttons, live dot |
| Border width | 2px | Cards, buttons, inputs, steps, chips, stars, pill, tab bar |
| Thin border | 1px `--hair` | Table rows, share items, accordion rules; 1.5px for `.srcs span` and dashed `.feeds` |

The chunky bottom-edge shadow is the signature: a hard shadow with zero blur, offset straight down, in a solid colour. It reads as a raised block.

| Element | Shadow |
|---|---|
| `.card` | `0 7px 0 var(--coral)` |
| `.fill` | `0 5px 0 var(--fill-deep)` |
| `.pill`, `.fab` | `0 4px 0 var(--coral)` |
| `.primary` | `0 5px 0 var(--coral)`; on hover `0 5px 0 var(--fill-deep)` |
| `.sharebox`, `.pick`, `#tabs` | `0 5px 0 var(--coral)` |
| Active step | `0 4px 0 var(--fill-deep)` |
| Highlighted phrase | `0 .12em 0 var(--fill-deep)` |

Frosted panels use `backdrop-filter: blur(18px) saturate(1.4)` on `.card`, and `blur(18px)` on the tab bar.

### Spacing

| Rule | Value |
|---|---|
| Page gutter | 16px each side |
| Card padding | 22px |
| Card bottom margin | 24px |
| Button minimum height | 48px (host nav and clock: 44px; step and matrix buttons reset to 0) |
| Button padding | 12px 14px |
| Grid gaps | 5 to 10px for dense grids (steps 8px, ladder 5px, chips 6px, options 10px) |
| Callout margin top | 20px |
| Paragraph margin bottom | 12px |
| Label margin top | 12px |

### Motion

| Name | Duration and easing | Used by |
|---|---|---|
| `pulse` | 1.6s, infinite; opacity to .25 at 50% | Live dot before `.live` |
| `fly` | 1.4s ease-in-out, infinite (2s on touch devices, always on) | Icon in `.cta` buttons: plane flies off and back in |
| `in-next`, `in-prev` | .38s `cubic-bezier(.2, .8, .2, 1)`, from `translateX(+28px / -28px)` and opacity 0 | `.next`, `.prev` wrappers: slides and questions enter from the side you are heading to |
| `rise` | .38s same easing, from `translateY(14px)` and opacity 0 | `.rise` wrappers, dialogs (.3s), active ladder cell and active step (.4s, .25s delay) |
| `pop` | .5s `cubic-bezier(.3, 1.6, .5, 1)`, .18s delay, from scale .6 and rotate | The highlighted phrase in `h1 mark` |
| `grow` | .8s ease-out, .1s delay, from `width: 0` | Bar fills |
| `glow` | 2.2s ease-in-out, infinite; fill and drop-shadow brighten | Share box bulb |
| `floatup` | 2.4 to 3.2s (random per emoji; 2.8s default) ease-out | Floating reactions |
| Hover lift | `.12s`, `translateY(-1px)` | Buttons (not step, matrix, or disabled) |

Children of `.next`, `.prev` and `.rise` stagger: 2nd child .05s, 3rd .1s, 4th .15s, 5th onward .2s.

Reduced motion: a global `prefers-reduced-motion: reduce` rule sets `animation: none` and `transition: none` on everything. The brain canvas draws one still frame instead of animating. Floating reactions use the Web Animations API with a plain 1200ms fade, because the global rule would otherwise freeze them in place.

## Components

### Card (frosted panel)
`.card`: `--glass` background, blur and saturate, 2px coral border, 18px radius, coral drop edge `0 7px 0`, 22px padding, 24px bottom margin. Used for every screen block and for the dialog (which overrides background to the 92% version and width).

### Pill label
`.pill`: inline-flex, two parts in one rounded box with a 2px coral border and `0 4px 0` coral edge. Left part `b`: paper background, ink text, mono uppercase (the key, such as "Round 1"). Right part `span`: Poppins 700, on ink (the value). Always the first element of a screen. Built from a two-item array `[key, value]`.

### Title with highlighted phrase
`h1` with a `mark` inside. In the content, the phrase to highlight is wrapped in square brackets, for example `The Project [Brain]`. The `mark` is an inline-block coral chip with ink text, rotated -1.6 degrees, `.22em` radius, `0 .12em` deep edge, and the `pop` animation.

### Filled coral callout
`.fill`: solid coral background, ink text, 14px radius, `0 5px 0` deep edge, padding `16px 18px`, top margin 20px. Contains a `.label` (ink, block, 6px below) and one `p` in Poppins 700 19px. Used for "At the table" prompts, "On Monday" action, the Home notice, and in the host view for the pulse and average rating summaries.

### Step buttons
Four buttons in a 4-column grid (`.steps`, gap 8px, top margin 22px). Each shows its number (Poppins 800, 22px, coral) above the word. The four words, in order: Remember, Act, Connect, Trust. Tapping jumps to the first slide for that word (audience: browse; host: go live).

| State | Class | Look |
|---|---|---|
| Upcoming | none | Transparent, 2px `--hair` border, `--soft` text |
| Done | `.done` | Coral border, paper text |
| Current | `.on` | Solid coral fill, ink text, `0 4px 0` deep edge, `rise` animation |

State comes from the position of the current slide: slides tied to a word mark that word current and earlier words done. Slides after the rounds mark all four done. Slides before the rounds mark none. A slide can hide the row with a flag.

### Slide pager
A 3-column grid (`52px 1fr 52px`, gap 10px, top margin 16px, centred text), directly under the slide content. Left and right are square arrow buttons (previous, next), disabled at the ends. The middle shows one of two states:

| State | Middle content |
|---|---|
| Following live | A `.label.live` text: "Following ... live · N of total" with the pulsing dot |
| Browsing elsewhere | A `.primary` button "Back to live" plus the live slide's short nav name (44px high, 15px) |

The pager is hidden in the host view.

### Choice cards on Home
`.pick`: a full-width button. 2-column grid (icon tile, then text), 6px by 14px gap, 16px padding, 2px coral border, 14px radius, `0 5px 0` coral edge, faint paper background, hover tint. Anatomy: icon tile (42px paper square, 9px radius, ink icon), strong title (Poppins 700, 19px, paper), description, a small coral status label, and a paper "CTA arrow" chip in the second column (Poppins 700, 14px, ink on paper, 8px radius). The status line is live: the Presentation card shows the current live slide; the check card shows "Not started", "n of N answered", or the level reached. The CTA word changes with state (Start, Continue, See result).

### Share box panel
`.sharebox`: a paper-coloured panel on the dark page, ink text, 14px radius, 16px padding, `0 5px 0` coral edge, margin `16px 0 4px`. Every colour is restated so it reads on light. Order: head row (40px bulb tile with an animated yellow bulb icon, then the title in Poppins 700 18px), a hidden confirmation line, then the form: kind chips, a 3-row text area, an optional name field, an error line, a full-width ink button. Inputs inside have white background and a 30% ink border. The primary button inside is ink with paper text and no shadow or lift.

### Kind chips
`.chips`: 3 equal columns, 6px gap, radio inputs hidden over a pill-shaped `span` (99px radius, 2px border, 13.5px, 700). Checked: coral fill and border, ink text. Focus ring is drawn on the span. The checked kind also swaps the text area placeholder. Default checked: the third kind. Home also shows decorative `.kinds` chips (small coral-tint pills) that are not controls.

### Accordions
Native `details` and `summary`. Top rule 1px `--hair`. Summary is a flex row, space between, 13px vertical padding, weight 600, with the browser marker removed and a coral `+` (Poppins 800, 20px) that becomes `−` when open. The last child gets 14px bottom margin. The last `details` pulls up 10px so it sits flush with the card bottom. Used for "Your score per word", "Change my answers", the host's folded notes, Jump to a slide, and Join code.

### Primary button
`.primary`: paper background, ink text, paper border, Poppins 700 17px, `0 5px 0` coral edge. Hover: coral fill, deep edge. The call to action variant `.cta` adds a full-width centred row with an icon and two stacked labels: the task label (default) and a "win" label that replaces it on hover or keyboard focus (for example "Send me the framework" becomes "Get my playbook"). The icon plays `fly`. On touch devices there is no hover, so the icon animates all the time and the task label stays.

### Kind chips and other small chips
See Kind chips. The `.srcs` chips (3 columns, 6px gap) are plain bordered boxes: 1.5px `--hair` border, 8px radius, 12.5px, weight 600, centred.

### Star rating
`.stars`: 5 equal flex cells, 6px gap, top margin 14px. Each is a hidden radio over a `span` (min height 56px, 12px radius, 2px `--hair` border, 34px star glyph, `--soft`). The chosen star and all before it get `.on`: coral glyph and coral border. Radios give arrow-key support. The first radio is the required one.

### Reaction bar and floating reaction
Reaction bar `.react`: a centred row of five round buttons (48px wide, 22px emoji, 10px gap, 14px top margin) under the slide, audience only. Tapping sends the reaction and shows it locally. A 350ms cooldown limits taps. Floating reaction: a `span` in `#fx`, 34px emoji, starts at `bottom: 14%` and a random `left` between 8% and 92%, scales in, drifts up about 55vh while swaying sideways by a random offset up to 30px, and fades out. At most 30 are on screen at once. The host sees these too, plus a one-line tally of the last 60 seconds in the control card.

### Bottom tab bar
See page frame. 4 equal columns, 4px gap, 6px padding, 2px coral border, 18px radius, `0 5px 0` coral edge, 72% dark glass with blur. Each tab: no border, 48px minimum height, icon (20px) above a 10px label, `--soft`. Active tab: `--fill` background, ink text, `aria-current="page"`.

### The 2x2 matrix
`.matrix`: 2-column grid, gap `8px 10px`, top margin 18px. Row of two column labels (Knowledge, Action), then a full-width row label (axis label spans both columns and sits above its row so it works on a phone), then two cells, then the second row label and two cells. Each cell is a button: 2px `--hair` border, 12px radius, 12px padding, left aligned. Anatomy: icon and a coral number, title (Poppins 700, 17px), one 13.5px description in `--soft`. Hover turns the border coral. Tapping goes to the matching round. The second row is ordered 4 then 3, so the grid reads as a staircase of scope.

### Maturity ladder strip
`.ladder`: 4 equal columns, gap 5px, margin `16px 0`, Poppins 700 11.5px, centred. Each cell has a 2px `--hair` border, 8px radius, `10px 2px` padding, `--soft` text. The current level (`.on`) is inverted: paper fill, ink text. On the model slide no level is set, so it is shown as a plain legend of the four levels.

### Bars
`.bars`: 3-column grid (`auto 1fr auto`, gap `8px 12px`): word, track, value. Track `i` is 10px high, 5px radius, `--hair`, with a coral inner `b` whose width is the value over the maximum, animated by `grow`. Value text reads like "3/6". Used for the user's own score per word and for the host's table average (both out of 6).

### QR dialog
Native `<dialog>` styled as `.card.qr`, centred text. Contents: title (h2), a `.note` line, an inline SVG QR code on a white rounded square (max width 300px, 12px padding), a `.primary` link showing the URL without protocol, and a full-width Close button inside a `form method="dialog"`. The same QR style appears on the last slide and in the host Join code accordion.

### Progress dots
`.dots`: 8 equal columns (one per question), gap 5px, margin `14px 0 18px`. Each dot is a 6px high bar, 3px radius, `--hair`; reached ones are coral.

### Option buttons
`.opts`: stacked full-width buttons, 10px gap, left aligned. Selected: coral border and 20% coral background (`.sel`, `aria-pressed`).

### Table, steps list, tiles
Tables: full width, 15px, rows separated by a 1px `--hair` top border, 9px vertical padding. The "how it works" list (`.how`) is a numbered list with a 28px Poppins coral number (min width 22px), a bold title and a soft 15px explanation, 14px gap. Icon tiles (`.tile`): 34px paper squares, 9px radius, centred ink icon or letters.

## Screens in detail

The app follows order of operations: the thing to do now comes first, supporting detail comes after, and rarely used detail is folded into accordions.

### Home (`#home`)

1. Pill (welcome key, table name).
2. `h1` with highlighted phrase, then a lead line.
3. Filled coral callout: "this is a conversation" notice. First, because it sets the tone before any action.
4. Share box. The only thing the audience can do in the room, so it comes before navigation.
5. Intro line, then two choice cards: Presentation, then My check.
6. Closing note pointing to the Connect button.

### Presentation (`#live`, shares the `#slide` card with the host)

1. Pill from the slide tag.
2. `h1` title with highlighted phrase.
3. Lead paragraph (the slide body), if any.
4. Slide visual block (custom HTML such as the brain canvas, two-column comparison, or the matrix and ladder), if any.
5. QR block with link button and note, on the closing slide only.
6. Filled coral callout labelled "At the table" with the discussion prompt, if any.
7. Step buttons (four words), unless the slide hides them.
8. "Give feedback" button, on the closing slide only.
9. Pager (outside the animated wrapper, so it does not re-animate).
10. Reaction bar.

Rule: what the slide says, then what to do at the table, then where we are in the story, then how to move.

### My check (`#check`)

Three states in one card.

Intro:
1. Pill (name of the check, question count).
2. `h2` question for the check.
3. Three-step numbered list: answer, see the level, get the material by email.
4. Primary button "Start the check".
5. Privacy note.

Question:
1. Pill ("Question n of N", word label).
2. Progress dots.
3. Question `h2`.
4. Four option buttons.
5. Row: Back button, then either a hint or a Next button once an answer is picked. Picking an answer advances at once.

Result:
1. Pill ("Your result", level n of 4).
2. `h1` with the level name highlighted, then a lead description.
3. Ladder strip with the current level inverted.
4. Note: total out of 24 and what the next level looks like.
5. Filled callout "On Monday", naming the weakest word, with one action.
6. Contact form (name, work email, optional company, consent checkbox, error line, `.cta` button), or a confirmation line once sent.
7. Accordion: score per word (bars out of 6).
8. Accordion: change my answers (Review answers, Start over).

Rule: where you are, what to do on Monday, get the material. The detail (scores, editing) folds away.

### Feedback (`#feedback`)

1. Pill (feedback key, "1 minute").
2. `h2` question.
3. Five stars.
4. Two optional text areas (3 rows each, 500 character limit).
5. Error line, then the Send button.

After sending, it shows a thank-you with a "Change my feedback" link. Reopening the view shows the form again with the saved values.

### Host sign-in (`#host`, not signed in)

One card: `h2`, email, password, error line, full-width Sign in. The audience cards are hidden.

### Host view (`#host`, signed in)

The slide card is shown first (same render as the audience, without pager and reactions), then the host cards below it. The host card order:

1. Control card, in this order:
   1. Back and Next row (grid `1fr 2fr`, Next is the large primary button at 20px).
   2. Meta row: "Slide n of total · done by minute m" on the left, the clock button on the right.
   3. Round and total time lines, then a one-line reaction tally for the last minute.
   4. Error line, only if a slide change failed to save.
   5. Say: the sentence to read now, larger text, label in coral.
   6. The first two notes, always open.
   7. If the table is quiet: a prompt to restart conversation, if the slide has one.
   8. Bridge to next: the line to hand over, plus "Up next" with the next slide's short name.
   9. My notes: a private text area, 4 rows, 4000 character limit, with a save status line.
   10. The remaining notes, each folded in an accordion titled by the note's label.
2. Table pulse: how many finished the check, a callout with the weakest word, bars of the average per word, and a line with the count at each level.
3. From the table: shared items newest first with a count badge. Each item has the kind as a label, the text, and the name if given.
4. Feedback: a callout with the average rating and count, then the latest entry per person, newest first, with rating, "Useful" and "Different" lines.
5. Jump to a slide (accordion): buttons grouped by section, auto-fill grid with 140px minimum column, 8px gap, each with the slide's icon and short name. The current slide is coral.
6. Join code (accordion): QR for the page URL and the URL as text. Open by default on the first slide, closed otherwise.

Rule: move, say this now, read the table, then rarely used things folded away. Host cards 2 to 4 refresh without touching the control card.

The clock is red (`.late`, `#ff9c8c`) when elapsed time passes the slide's "done by" minute. The round line shows minutes left or minutes over.

## Content model

Content lives in constants at the top of the script (`WORDS`, `LEVELS`, `QUESTIONS`, `SLIDES`, `NAV`, `KINDS`, `EMOJI`, plus a link constant and an icon map). The layout reads from them, so it can be reused with different content without touching the render code.

Slide object (`SLIDES[i]`):

| Field | Type | Renders as |
|---|---|---|
| `nav` | string | Short name in the pager, tab line, jump list and "Up next" |
| `icon` | key of the icon map | Icon in the host jump list |
| `tag` | `[key, value]` | The pill. Also used in the "Now" line on Home |
| `title` | string, `[brackets]` mark the highlighted phrase | `h1` |
| `body` | string | Lead paragraph |
| `html` | HTML string | Visual block under the lead |
| `ask` | string | Text of the "At the table" callout |
| `word` | one of the four word keys | Ties the slide to a step, so step buttons can jump to it and show state |
| `nosteps` | boolean | Hides the step row |
| `link` | URL | QR code plus link button on that slide |
| `until` | number, minute of the talk | Host clock: "done by minute" and minutes left |
| `notes` | array of `[label, text]` | Host only. The first two show open, the rest fold |
| `say` | string | Host "Say" block |
| `quiet` | string, optional | Host "If the table is quiet" block |
| `bridge` | string, optional | Host "Bridge to next" block |

The `say`, `quiet` and `bridge` fields are merged into the slide objects from a second list by index, so the main list stays readable. Grouping for the jump list is `NAV`: an array of `[group name, [slide indexes]]`.

The four words (`WORDS`):

| Field | Meaning |
|---|---|
| `k` | Key used by questions and scores: `remember`, `act`, `connect`, `trust` |
| `icon` | Icon key |
| `label` | Display name: Remember, Act, Connect, Trust |
| `monday` | One-sentence action shown in the result callout when this word is the weakest |

Levels (`LEVELS`): four pairs of `[name, description]`, in order: Explorer, Practitioner, Integrator, Champion. The level comes from the total score (0 to 24, 8 questions at 0 to 3 each): 0 to 6, 7 to 12, 13 to 18, 19 to 24.

Question (`QUESTIONS[i]`): `[wordKey, question text, [four options]]`. Options are ordered from least to most mature, and the index picked (0 to 3) is the score. Two questions per word, so a word scores 0 to 6.

Reactions: `EMOJI` is an array of five emoji, `REACT_NAMES` the five accessible names, in the same order (thumbs up, love, applause, laugh, idea). Only the index travels over the network.

Share kinds (`KINDS`): `{ key: [label, placeholder] }` for three kinds: idea, experience, challenge. The key must match the database check constraint.

Icons (`I`): a map of 24 by 24 stroke paths. `icon(key)` wraps one in an SVG with class `.ic` (20px, no fill, 2px round stroke, `currentColor`).

## Behaviour that shapes the layout

- Two slide variables: `slide` is what this screen shows, `live` is where the host is.
- Live follow: if the audience member is on the live slide when the host moves, their view moves with it. If they have browsed elsewhere, they stay and only the pager changes, showing "Back to live". The "Now" line on Home updates in place.
- Free browsing: previous, next and step buttons change `slide` only. They never send anything.
- Host control: in the host view, any slide change writes the slide number to the database, and the host's own view follows at once.
- Sync: the live slide arrives by realtime subscription and a poll every 5 seconds as a fallback for unreliable venue wifi.
- Never re-render a form while someone types: the Home share form and Feedback form render only when the view opens or after submit. Live slide changes do not rebuild Home. The "Now" line is updated by changing its text only.
- Host notes: the notes text area is rebuilt when the slide changes. Pending text is saved first (800 ms after typing, on blur, and before any rebuild). A failed save retries after 5 seconds. Loaded notes never overwrite a slide with unsaved changes or the field in focus.
- Periodic refresh: in the host view the pulse, shared items and feedback each sit in their own container and refresh every 10 seconds, independent of the control card. The clock refreshes every 1 second. This keeps the notes box and buttons stable.
- Demo versus connected: when no Supabase URL is set, the status label reads "Demo mode" and all data goes to `localStorage`, with tabs of the same browser kept in sync by storage events and a `BroadcastChannel`. The host view needs no sign-in in demo mode. When connected, the host must sign in, and audience data goes to the database.
- Text limits on inputs: share text 500, share name 60, contact name 100, email 200, company 100, feedback texts 500 each, host notes 4000. Limits are set on the fields and again by trimming and slicing in code, and again by database constraints.
- Escaping: everything the audience types and the host sees (shared text, names, feedback, host notes) passes through `esc()`, which replaces `& < > " '` with numeric entities. Slide content is trusted and not escaped. Reaction indexes from the network are accepted only if they are integers within range.
- Reduced motion: see Design tokens, Motion.
- Resilience: a person's progress through the check, their anonymous id, and sent state live in `localStorage`. The check is stored as it goes, so a refresh keeps their place. A person who submits twice (once without contact, once with) is counted once in the host pulse (latest by id).
- Canvas: the brain picture is a canvas that redraws only while it is on screen and stops itself when the slide changes.

## Data and storage

Supabase Row Level Security is on for every table. The audience uses the anonymous (publishable) key. The host signs in with an email and password and is recognised by the email in the sign-in token. The host email is set once in `supabase.sql` before running it. Sign-ups should be turned off in your Supabase project.

| Table | Stores | Who can write | Who can read |
|---|---|---|---|
| `state` | One row (`id = 1`): the live slide number, 0 to 50 | Host only (update) | Anyone |
| `responses` | One row per check submission: person id, answers, scores per word, level, optional name, email, company, consent flag | Anyone (insert) | Host only |
| `shares` | Things shared at the table: person id, kind (`idea`, `experience`, `challenge`), text (1 to 500), optional name (up to 60) | Anyone (insert) | Host only |
| `host_notes` | One row per slide: private note text, up to 4000, with update time | Host only (insert, update) | Host only |
| `feedback` | Talk feedback: person id, rating 1 to 5, optional useful text and change text (up to 500 each) | Anyone (insert) | Host only |

Details that matter for the layout:

- `responses` rejects an email without consent (check constraint) and limits `answers` and `scores` to under 500 bytes and `level` to under 30 characters.
- `state` is added to the realtime publication so phones are pushed slide changes.
- The person id (`cid`) is a random UUID created per browser, used to merge repeat submissions.

Realtime broadcast: reactions use one broadcast channel, `reactions`, with one event, `r`, whose payload is the emoji index. There is no table. Broadcast does not echo to the sender, so the sender draws their own reaction locally. The host listens on the same channel for the floating emoji and the tally. In demo mode a `BroadcastChannel` between browser tabs takes its place.

The page needs two script libraries from a CDN: the Supabase client and a QR code generator.

## Reuse checklist

1. Copy the repo and open `index.html`. Keep the structure. Work only in the constants block at the top of the script and the `:root` variables.
2. Replace the content constants: `WORDS`, `LEVELS`, `QUESTIONS`, `SLIDES` (including `say`, `quiet`, `bridge`, `notes` and `until` times), `NAV`, `KINDS`. If you change the number of questions or words, check the scoring ranges: the level thresholds assume 8 questions at 0 to 3 each, and the bars assume a maximum of 6 per word.
3. Update the header pill (event code and table name), the page `<title>`, the credit line in the footer, the Connect dialog text and the link constant.
4. Put your logos in the `logos/` folder (host logo, organisation logo, and any product logos used on the visual slide). Keep the file names the code expects or change them in the footer and the logo helper. Missing files fall back to letters or are removed.
5. Change the palette by editing the `:root` variables: `--coral`, `--fill`, `--fill-deep`, `--coral-text`, `--ink`, `--paper`, `--soft`, `--glass`, `--hair`. The three glows in `body::before` and the hard-coded `rgba(229, 65, 43, ...)` tints use the coral value directly, so search for `229, 65, 43` and update those too.
6. Create a Supabase project. Create a host user under Authentication, turn off new sign-ups, then paste `supabase.sql` into the SQL editor after replacing `HOST_EMAIL` with that host's email, and run it.
7. In `index.html`, set the project URL and the publishable key in the two config constants at the top of the script. Both are safe to publish. Leave them empty to run in demo mode.
8. Publish the folder as a static page (for example GitHub Pages). Generate a QR code for the page URL and put it on your opening slide or table card.
9. Test with two devices: open the page on a phone, open `#host` on a laptop, sign in, and move the slides. Check that the phone follows, that browsing away shows "Back to live", that a check submission appears in Table pulse, that a share appears in From the table, and that a reaction floats on both screens.
10. Rehearse with the host clock: start it on slide one, and adjust each slide's `until` value to match your own timing.
