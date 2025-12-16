import { useState } from 'react';
import { HashRouter, Routes, Route } from 'react-router-dom';
import { HelmetProvider } from 'react-helmet-async';
import { Layout } from '@/components/layout';
import { Home, Installation, Projects, Diagrams, Documentation } from '@/pages';
import { GitHubStatsProvider } from '@/context/GitHubStatsContext';
import { ScrollToTop, SplashScreen, MouseTrail } from '@/components/common';

function App() {
  const [isLoading, setIsLoading] = useState(true);

  return (
    <HelmetProvider>
      <GitHubStatsProvider>
        {/* Splash Screen */}
        {isLoading && (
          <SplashScreen
            onLoadComplete={() => setIsLoading(false)}
            minDisplayTime={1800}
          />
        )}

        {/* Mouse Trail Effect */}
        <MouseTrail />

        {/* Main App - renders behind splash screen */}
        <div className={isLoading ? 'opacity-0' : 'opacity-100 transition-opacity duration-500'}>
          <HashRouter>
            <ScrollToTop />
            <Routes>
              <Route path="/" element={<Layout />}>
                <Route index element={<Home />} />
                <Route path="installation" element={<Installation />} />
                <Route path="documentation" element={<Documentation />} />
                <Route path="projects" element={<Projects />} />
                <Route path="diagrams" element={<Diagrams />} />
              </Route>
            </Routes>
          </HashRouter>
        </div>
      </GitHubStatsProvider>
    </HelmetProvider>
  );
}

export default App;
