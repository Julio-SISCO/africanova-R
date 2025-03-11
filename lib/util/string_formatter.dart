String capitalizeEachWord(String input) {
  return input.split(' ').map((word) {
    return word.length > 1
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : word.toUpperCase();
  }).join(' ');
}
