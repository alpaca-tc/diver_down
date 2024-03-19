import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Route, Routes } from "react-router-dom";

import { Layout } from "./components/Layout"
import { path } from './constants/path';
import { Show as DefinitionShow } from "./pages/Definitions"
import { NotFound } from "./pages/Errors"
import { Show as Home } from "./pages/Home"
import { Show as SourceShow } from "./pages/Sources"

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route path={path.home()} element={<Home />} />
          <Route path={path.definitions.show(':bit_id')} element={<DefinitionShow />} />
          <Route path={path.sources.show(':source_name')} element={<SourceShow />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </React.StrictMode>,
)
