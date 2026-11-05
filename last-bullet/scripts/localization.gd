extends Node
const Catalog = preload("res://scripts/localization_catalog.gd")
class RuntimeTranslation extends Translation:
	var service: Node
	var target := "vi"
	func _get_message(source: StringName, _context: StringName) -> StringName:
		return StringName(service.render_message(str(source),target)) if is_instance_valid(service) else source
var language := "vi"
var preference_path := "user://records-language.cfg"
var resources: Array[Translation] = []
var inverse: Dictionary = {}
var patterns: Array[Dictionary] = []
var cache: Dictionary = {}
var fragments: Array[Array] = []
func _ready() -> void:
	for key in Catalog.PAIRS:
		var value: String = Catalog.PAIRS[key]
		inverse[value] = key
		if str(key).contains("%"):
			patterns.append({"vi":make_pattern(str(key)),"en":make_pattern(value),"source":str(key),"translated":value})
		if str(key).length() >= 2 and str(key) != value: fragments.append([str(key),value])
	patterns.sort_custom(func(a,b): return a.source.length() > b.source.length())
	inverse["BACK"] = "QUAY LẠI"
	fragments.sort_custom(func(a,b): return maxi(a[0].length(),a[1].length()) > maxi(b[0].length(),b[1].length()))
	for code in ["vi","en"]:
		var resource := RuntimeTranslation.new(); resource.service = self; resource.target = code; resource.locale = code
		TranslationServer.add_translation(resource); resources.append(resource)
	var config := ConfigFile.new()
	if config.load(preference_path) == OK: language = str(config.get_value("language","selected","vi"))
	if language not in ["vi","en"]: language = "vi"
	TranslationServer.set_locale(language)
func _exit_tree() -> void:
	for resource in resources: TranslationServer.remove_translation(resource)
	resources.clear()
func set_language(code: String) -> void:
	if code not in ["vi","en"]: return
	language = code
	TranslationServer.set_locale(code)
	var config := ConfigFile.new(); config.set_value("language","selected",code); config.save(preference_path)
func t(source: String) -> String: return render_message(source,language)
func make_pattern(source: String) -> RegEx:
	var result := "^"; var i := 0
	while i < source.length():
		var char := source[i]
		if char == "%" and i+1 < source.length():
			if source[i+1] == "%": result += "%"; i += 2; continue
			var j := i+1
			while j < source.length() and source[j] in ".0123456789": j += 1
			if j < source.length() and source[j] in "dsf":
				result += "([\\s\\S]*?)" if source[j] == "s" else "(-?[0-9][0-9.,]*)"
				i = j+1; continue
		if char in "\\.^$|?*+()[]{}": result += "\\"
		result += char; i += 1
	result += "$"
	var regex := RegEx.new()
	regex.compile(result)
	return regex
func fill_template(template: String, values: PackedStringArray) -> String:
	var result := ""; var i := 0; var field := 1
	while i < template.length():
		if template[i] == "%" and i+1 < template.length():
			if template[i+1] == "%": result += "%"; i += 2; continue
			var j := i+1
			while j < template.length() and template[j] in ".0123456789": j += 1
			if j < template.length() and template[j] in "dsf" and field < values.size():
				result += values[field]; field += 1; i = j+1; continue
		result += template[i]; i += 1
	return result
func render_message(source: String, code: String) -> String:
	var key := code+":"+source
	if cache.has(key): return cache[key]
	var result := source
	if code == "en" and Catalog.PAIRS.has(source): result = Catalog.PAIRS[source]
	elif code == "vi" and inverse.has(source): result = inverse[source]
	elif (code == "vi" and Catalog.PAIRS.has(source)) or (code == "en" and inverse.has(source)): result = source
	else:
		var found := false
		for pattern in patterns:
			var match_result: RegExMatch = pattern.vi.search(source) if code == "en" else pattern.en.search(source)
			if match_result != null:
				var values := match_result.strings
				for i in range(1,values.size()): values[i] = render_message(values[i],code)
				result = fill_template(pattern.translated if code == "en" else pattern.source,values); found = true; break
		if not found and source.contains("\n"):
			var lines := source.split("\n")
			for i in range(lines.size()): lines[i] = render_message(lines[i],code)
			result = "\n".join(lines)
		elif not found:
			for pair in fragments:
				var old: String = pair[0] if code == "en" else pair[1]
				var new: String = pair[1] if code == "en" else pair[0]
				if not old.contains("%") and old.length() >= 2: result = replace_phrase(result,old,new)
	if cache.size() >= 2048: cache.clear()
	cache[key] = result
	return result

func replace_phrase(source: String, old: String, value: String) -> String:
	var result := source; var offset := 0
	while offset < result.length():
		var found := result.find(old,offset)
		if found < 0: break
		var end := found+old.length()
		var left_ok := found == 0 or not (result[found-1].is_valid_identifier() or result[found-1].is_valid_int())
		var right_ok := end == result.length() or not (result[end].is_valid_identifier() or result[end].is_valid_int())
		if left_ok and right_ok:
			result = result.substr(0,found)+value+result.substr(end); offset = found+value.length()
		else: offset = end
	return result
