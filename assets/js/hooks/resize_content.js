const ResizeContent = {
    mounted() {
      this.handleResize();
      this.handleEvent("toggle_sidebar", () => this.handleResize());
    },
  
    handleResize() {
      const mainContent = document.getElementById("main-content");
      const sidebar = document.getElementById("sidebar");
      
      if (window.innerWidth >= 1024) { // lg breakpoint
        if (sidebar.querySelector("div").classList.contains("max-h-0")) {
          mainContent.classList.remove("lg:w-3/4");
          mainContent.classList.add("lg:w-full");
        } else {
          mainContent.classList.remove("lg:w-full");
          mainContent.classList.add("lg:w-3/4");
        }
      } else {
        mainContent.classList.remove("lg:w-3/4", "lg:w-full");
      }
    }
  };
  
  export default ResizeContent;