const ATTR_DISPLAY = 'sidebar-display';
const ATTR_COLLAPSED = 'sidebar-collapsed';
const $sidebar = document.getElementById('sidebar');
const $trigger = document.getElementById('sidebar-trigger');
const $mask = document.getElementById('mask');
const desktopMedia = matchMedia('(min-width: 850px)'); /* breakpoint `lg` */

class SidebarUtil {
  static #isExpanded = false;

  static toggle() {
    this.#isExpanded = !this.#isExpanded;
    document.body.toggleAttribute(ATTR_DISPLAY, this.#isExpanded);
    $sidebar.classList.toggle('z-2', this.#isExpanded);
    $mask.classList.toggle('d-none', !this.#isExpanded);
  }

  static toggleCollapse() {
    const collapsed = document.documentElement.toggleAttribute(ATTR_COLLAPSED);

    try {
      if (collapsed) {
        localStorage.setItem(ATTR_COLLAPSED, '1');
      } else {
        localStorage.removeItem(ATTR_COLLAPSED);
      }
    } catch {
      /* storage unavailable: keep the state for this page only */
    }
  }
}

export function initSidebar() {
  $trigger.onclick = () =>
    desktopMedia.matches ? SidebarUtil.toggleCollapse() : SidebarUtil.toggle();
  $mask.onclick = () => SidebarUtil.toggle();
}
