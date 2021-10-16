window.closeElement = function () {
  const elementToClose = document.getElementById("close-element");
  console.log(elementToClose);
  elementToClose.style.removeProperty('display')
  elementToClose.hidden = true;
};
