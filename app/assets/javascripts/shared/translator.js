function tf(field) {
  let translation = TRANSLATIONS[field];

  if(translation === undefined) {
    return 'translation ' + field + ' was not found or preloaded'
  }

  return translation
}
