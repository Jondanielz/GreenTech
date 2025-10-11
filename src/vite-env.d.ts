/// <reference types="vite/client" />

declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<{}, {}, any>;
  export default component;
}

// Declaraciones para módulos sin tipos
declare module "jquery";
declare module "bootstrap";
declare module "chart.js";
declare module "bootstrap-datepicker";
declare module "select2";
declare module "perfect-scrollbar";
declare module "owl-carousel-2";
declare module "pwstabs";
declare module "typeahead.js";
declare module "jquery-file-upload";
