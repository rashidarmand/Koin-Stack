// Initialize all materialize plugins
M.AutoInit();

let closeButton = document.querySelector(".close-button")
let flashPanel = document.querySelector(".flash")

closeButton.addEventListener("click", event => {
  event.preventDefault()

  flashPanel.classList.add("hide")
})

window.setTimeout(() => {
  flashPanel.classList.add("hide")
}, 3000);


