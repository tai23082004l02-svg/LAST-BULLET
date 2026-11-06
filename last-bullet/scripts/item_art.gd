extends RefCounted
# Shared illustrated weapon/pet sprites and vector equipment/support art.
static var sheets: Dictionary = {}
static var cache: Dictionary = {}
static func texture(group: String, index: int) -> Texture2D:
	var key := group+str(index)
	if cache.has(key): return cache[key]
	if group in ["weapon","pet"] and index >= 0 and index < (12 if group == "weapon" else 6):
		var illustrated := illustrated_texture(group,index)
		if illustrated != null:
			cache[key] = illustrated
			return illustrated
	var colors := ["83ead6","ffd278","9adfff","ffa56b","caa0ff","8ebdff"]
	var accent: String = colors[posmod(index,6)]
	if group == "gear": accent = ["9adfff","83ead6","ffa56b"][index/4]
	var body := ""
	if group == "weapon":
		match index:
			8: body = '<path d="M94 32Q177 128 94 224L81 211Q142 128 81 45Z" fill="url(#metal)" stroke="#c3ff9c" stroke-width="5"/><path d="M90 37L64 128L90 219M55 128H214M197 115L218 128L197 141" fill="none" stroke="#dcffc9" stroke-width="4"/><path d="M54 117L76 128L54 139" fill="#89d36f"/>'
			9: body = '<path d="M42 52L74 35L219 128L74 221L42 204L147 128Z" fill="url(#metal)" stroke="#88ffdd" stroke-width="5"/><path d="M69 57L178 128L69 199L155 128Z" fill="#316f76"/><path d="M157 118L176 128L157 138" fill="#c7fff2"/>'
			10: body = '<rect x="60" y="67" width="116" height="105" rx="24" fill="url(#metal)" stroke="#ffc875" stroke-width="4"/><rect x="163" y="77" width="61" height="85" rx="12" fill="#263b54" stroke="#8fa8be" stroke-width="4"/><ellipse cx="207" cy="120" rx="16" ry="31" fill="#101e2c" stroke="#ffd47f" stroke-width="5"/><path d="M75 162L61 211H91L111 163" fill="#26394b" stroke="#7891a5" stroke-width="4"/><circle cx="113" cy="118" r="25" fill="#172b40" stroke="#ffb86f" stroke-width="5"/><path d="M105 105L123 118L105 131" fill="#fff1b9"/>'
			7: body = '<path d="M30 87L180 63L224 90V145L178 165L30 148Z" fill="url(#metal)" stroke="#ffa56b" stroke-width="4"/><path d="M39 97L177 80L201 96V130L177 148L39 139Z" fill="#243b51"/><ellipse cx="205" cy="112" rx="18" ry="27" fill="#111d2a" stroke="#ffb875" stroke-width="5"/><path d="M55 151L43 196H77L94 151" fill="#29465b" stroke="#7f99ae" stroke-width="4"/><path d="M75 101H160V124H75Z" fill="#ffb36b"/><path d="M176 83L191 96L176 110" fill="#fff3c9"/>'
			_:
				body = '<path d="M34 96L61 67H165L186 83H224V132H183L163 158H98L80 200H47L57 152H34Z" fill="url(#metal)" stroke="#8daabe" stroke-width="4"/><path d="M50 100L70 82H157L171 97V130L151 143H75L50 131Z" fill="#18334b"/><path d="M169 92H232V122H169Z" fill="#304c62" stroke="#b1c5d4" stroke-width="3"/><path d="M68 91H148V115H68Z" fill="#'+accent+'"/><path d="M70 97H133" stroke="#efffff" stroke-width="5"/><path d="M66 152L58 188H73L89 150Z" fill="#172b3e"/>'
				if index == 4: body += '<path d="M155 68L185 102L155 139L132 103Z" fill="#ab7fe8" stroke="#f6d9ff" stroke-width="4"/><path d="M170 104H236" stroke="#e9c4ff" stroke-width="8"/>'
				elif index == 5: body += '<path d="M165 71H231V88H165ZM165 131H231V148H165Z" fill="#a5b7c6"/><circle cx="225" cy="80" r="5" fill="#233746"/><circle cx="225" cy="140" r="5" fill="#233746"/>'
				elif index == 3: body += '<path d="M78 126H151V163H78Z" fill="#a35e32" stroke="#ffd18c" stroke-width="3"/><path d="M93 153L105 130L112 145L128 128L139 153Z" fill="#ffba66"/>'
				elif index == 2: body += '<path d="M86 105L97 91L112 105L97 120Z" fill="#e2fcff"/><path d="M98 85V125M78 105H118" stroke="#a0edff" stroke-width="3"/>'
				elif index == 11: body += '<rect x="93" y="125" width="38" height="59" rx="10" fill="#b3ef69" stroke="#edffb1" stroke-width="4"/><path d="M104 140L121 159L103 168Z" fill="#436b3c"/>'
				elif index == 1: body += '<path d="M121 83L98 111H119L101 139L145 104H122L139 83Z" fill="#fff2a0"/>'
	elif group == "gear":
		match index%4:
			0: body = '<path d="M53 49L92 31L113 55H143L164 31L203 49L221 95L195 119L178 99L182 209L128 232L74 209L78 99L61 119L35 95Z" fill="url(#metal)" stroke="#'+accent+'" stroke-width="5"/><path d="M86 81L128 105L170 81L164 172L128 195L92 172Z" fill="#1b3b51" stroke="#628697" stroke-width="3"/><path d="M108 100L128 116L148 100L145 151L128 168L111 151Z" fill="#'+accent+'"/><path d="M80 187L127 208L176 187" fill="none" stroke="#94b6c8" stroke-width="5"/>'
			1: body = '<path d="M128 24L180 55L210 107L210 153L180 202L128 232L76 202L46 153V107L76 55Z" fill="url(#metal)" stroke="#'+accent+'" stroke-width="5"/><circle cx="128" cy="128" r="70" fill="#122d40" stroke="#738ea3" stroke-width="8"/><circle cx="128" cy="128" r="51" fill="#284d60" stroke="#'+accent+'" stroke-width="5"/><path d="M128 75L160 128L128 182L96 128Z" fill="#'+accent+'"/><path d="M128 90L141 126L128 157L116 126Z" fill="#edffff"/>'
			2: body = '<path d="M47 53L94 36L110 62V163L78 189L34 157V77Z M162 36L209 53L222 77V157L178 189L146 163V62Z" fill="url(#metal)" stroke="#'+accent+'" stroke-width="5"/><path d="M49 80H94V140H49Z M162 80H207V140H162Z" fill="#1b3648"/><path d="M53 148H91V171H53Z M165 148H203V171H165Z" fill="#'+accent+'"/><path d="M57 181L72 231L87 181Z M169 181L184 231L199 181Z" fill="#'+accent+'"/><path d="M67 186L72 216L77 186Z M179 186L184 216L189 186Z" fill="#efffff"/>'
			3: body = '<path d="M59 53H197V203H59Z" fill="url(#metal)" stroke="#'+accent+'" stroke-width="5"/><path d="M82 79H174V177H82Z" fill="#153348" stroke="#7594a5" stroke-width="3"/><path d="M128 91L159 128L128 166L97 128Z" fill="#'+accent+'"/><path d="M28 73H56M28 103H56M28 133H56M28 163H56M200 73H228M200 103H228M200 133H228M200 163H228" stroke="#adbdc7" stroke-width="9"/>'
	elif group == "pet":
		var addons := [
		'<path d="M67 103L28 70L17 113L62 140M189 103L228 70L239 113L194 140" fill="#ffcb75" stroke="#ffe5b5" stroke-width="4"/>',
		'<path d="M55 51V96Q55 144 91 144Q127 144 127 96V51H103V96Q103 117 91 117Q79 117 79 96V51Z" transform="translate(37 -17)" fill="#8fe2ff" stroke="#dbf7ff" stroke-width="4"/>',
		'<path d="M116 36H140V55H159V78H140V97H116V78H97V55H116Z" fill="#b4ffd9" stroke="#edfff3" stroke-width="3"/>',
		'<path d="M72 64L128 38L184 64L177 109L128 134L79 109Z" fill="#709bc9" stroke="#cee5ff" stroke-width="5"/>',
		'<path d="M128 22L153 65L128 105L103 65Z M49 89L75 104L51 126L32 108Z M207 89L224 108L205 126L181 104Z" fill="#b8eaff" stroke="#e9fcff" stroke-width="4"/>',
		'<path d="M65 76L40 30L24 78L46 115M191 76L216 30L232 78L210 115" fill="#f4a06b" stroke="#ffe0b5" stroke-width="4"/><path d="M122 41L145 23" stroke="#b6c3cb" stroke-width="7"/><circle cx="149" cy="21" r="8" fill="#ffbf74"/>'
		]
		body = addons[index]+'<path d="M74 84L104 71H152L182 84L204 123L192 170L162 192H94L64 170L52 123Z" fill="url(#metal)" stroke="#'+accent+'" stroke-width="5"/><path d="M76 110L100 99H156L180 110V146L155 160H101L76 146Z" fill="#0d2031" stroke="#617b90" stroke-width="4"/><path d="M86 119H115V134H86ZM141 119H170V134H141Z" fill="#'+accent+'"/><path d="M98 177H158" stroke="#c2d2db" stroke-width="5"/><path d="M73 181L58 207H82L103 190M183 181L198 207H174L153 190" fill="#55758c" stroke="#9dc0d5" stroke-width="4"/>'
	elif group == "skill":
		var symbols := [
		'<path d="M128 49L187 76L178 148L128 199L78 148L69 76Z" fill="#81f5d5"/><path d="M128 72V173" stroke="#efffff" stroke-width="8"/>',
		'<path d="M140 42L72 135H116L100 211L190 107H145L163 42Z" fill="#ffe08c"/>',
		'<path d="M128 51V205M61 90L195 166M61 166L195 90" stroke="#c6f4ff" stroke-width="12"/><path d="M110 71L128 89L146 71M110 185L128 167L146 185" fill="none" stroke="#e9fcff" stroke-width="7"/>',
		'<path d="M81 191Q39 140 100 88L107 123L148 44Q152 103 187 133Q211 177 169 202Z" fill="#ffb36c"/><path d="M112 186Q86 152 134 122Q128 154 154 176L142 201Z" fill="#fff0a8"/>',
		'<path d="M49 75L207 181M49 128H207M49 181L207 75" stroke="#d4a4ff" stroke-width="12"/><circle cx="128" cy="128" r="23" fill="#f3deff"/>',
		'<path d="M81 187L105 63L128 39L151 63L175 187L128 162Z" fill="#ffb879"/><path d="M117 176L128 217L139 176" fill="#fff0b0"/>',
		'<path d="M55 80L113 128L55 176M118 80L176 128L118 176" fill="none" stroke="#a3ffe8" stroke-width="20"/>'
		]
		body = '<circle cx="128" cy="128" r="96" fill="#142c43" stroke="#'+accent+'" stroke-width="5"/>'+symbols[index]
	else:
		match index:
			0: body = '<path d="M91 42H165L180 64V94H210V194H46V94H76V64Z" fill="url(#metal)" stroke="#a1ffe0" stroke-width="5"/><path d="M115 109H141V133H166V159H141V183H115V159H90V133H115Z" fill="#a4f9d8"/>'
			1: body = '<path d="M128 27L191 73L207 145L162 212H94L49 145L65 73Z" fill="url(#metal)" stroke="#d5aaff" stroke-width="5"/><path d="M128 58L170 123L128 193L86 123Z" fill="#b58beb"/><path d="M128 76L145 126L128 164L111 126Z" fill="#f2dcff"/>'
			2: body = '<path d="M42 76L85 48L131 76V135L85 165L42 135Z M111 126L158 97L209 126V188L158 219L111 188Z" fill="url(#metal)" stroke="#8eddff" stroke-width="5"/><path d="M57 82L85 64L114 82L85 101Z M128 133L158 114L191 133L158 152Z" fill="#8eddff"/>'
			_: body = '<path d="M42 53H214V96Q186 111 214 126V201H42V126Q70 111 42 96Z" fill="url(#metal)" stroke="#ffd482" stroke-width="5"/><path d="M117 79L90 132H121L105 176L171 116H136L158 79Z" fill="#ffe6a5"/>'
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256"><defs><linearGradient id="metal" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#8eafc4"/><stop offset=".28" stop-color="#3e627e"/><stop offset=".65" stop-color="#1b3048"/><stop offset="1" stop-color="#4a6c84"/></linearGradient></defs><ellipse cx="128" cy="222" rx="81" ry="12" fill="#020c1b" opacity=".45"/>'+body+'</svg>'
	var image := Image.new()
	if image.load_svg_from_string(svg) != OK: return null
	image.generate_mipmaps()
	var result := ImageTexture.create_from_image(image)
	cache[key] = result
	return result
static func draw(canvas: CanvasItem, group: String, index: int, center: Vector2, width: float, tint := Color.WHITE) -> void:
	var asset := texture(group,index)
	if asset != null: canvas.draw_texture_rect(asset,Rect2(center-Vector2.ONE*width*0.5,Vector2.ONE*width),false,tint)

# Decode each atlas once, fit its cell into a shared 256px texture and cache it.
# Keep square texture API so previews/collection/world pets use identical assets.
static func illustrated_texture(group: String, index: int) -> Texture2D:
	if not sheets.has(group):
		var source: Texture2D = load("res://art/arsenal/"+("pets" if group == "pet" else "weapons")+".png")
		if source == null: return null
		sheets[group] = source.get_image()
	var sheet: Image = sheets[group]
	var columns := 3 if group == "pet" else 4
	var rows := 2 if group == "pet" else 4
	var start := Vector2i(index%columns*sheet.get_width()/columns,index/columns*sheet.get_height()/rows)
	var end := Vector2i((index%columns+1)*sheet.get_width()/columns,(index/columns+1)*sheet.get_height()/rows)
	var cell := sheet.get_region(Rect2i(start,end-start))
	var bounds := cell.get_used_rect()
	if bounds.size.x <= 0 or bounds.size.y <= 0: return null
	var sprite := cell.get_region(bounds)
	var scale := 232.0/maxf(sprite.get_width(),sprite.get_height())
	sprite.resize(maxi(1,roundi(sprite.get_width()*scale)),maxi(1,roundi(sprite.get_height()*scale)),Image.INTERPOLATE_LANCZOS)
	var target := Image.create(256,256,false,Image.FORMAT_RGBA8)
	target.fill(Color.TRANSPARENT)
	target.blit_rect(sprite,Rect2i(Vector2i.ZERO,sprite.get_size()),(Vector2i(256,256)-sprite.get_size())/2)
	target.generate_mipmaps()
	return ImageTexture.create_from_image(target)
