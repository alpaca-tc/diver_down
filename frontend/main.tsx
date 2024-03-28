import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Route, Routes } from "react-router-dom";

import { Layout } from "./components/layout"
import { path } from './constants/path';
import { NotFound } from "./pages/Errors"
import { Show as Home } from "./pages/Home"
import { Index as SourceIndex, Show as SourceShow } from "./pages/Sources"

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout isLoading={false} />}>
          <Route path={path.home()} element={<Home />} />
          <Route path={path.sources.index()} element={<SourceIndex />} />
          <Route path={path.sources.show(':source_name')} element={<SourceShow />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </BrowserRouter>
  </React.StrictMode>,
)
