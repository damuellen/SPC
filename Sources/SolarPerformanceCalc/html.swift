// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

/// Symbols left and right
func icons() -> String {
  """
  <svg version="1.1" class="right" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 256 256" enable-background="new 0 0 256 256" xml:space="preserve"><g><g><path d="M184.5,234.2c-32.9-34.9-65.9-69.9-98.8-104.8c32.7-35.9,65.3-71.7,98-107.6c5.9-6.5-3.7-16.2-9.7-9.7c-34.2,37.5-68.3,75-102.5,112.5c-2.8,3-2.1,6.7-0.1,9.2c0.3,0.6,0.7,1.1,1.2,1.6c34.1,36.1,68.2,72.3,102.2,108.4C180.9,250.3,190.5,240.6,184.5,234.2z"/></g></g></svg>
  <svg version="1.1" class="left" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 256 256" enable-background="new 0 0 256 256" xml:space="preserve"><g><g><path d="M184.5,234.2c-32.9-34.9-65.9-69.9-98.8-104.8c32.7-35.9,65.3-71.7,98-107.6c5.9-6.5-3.7-16.2-9.7-9.7c-34.2,37.5-68.3,75-102.5,112.5c-2.8,3-2.1,6.7-0.1,9.2c0.3,0.6,0.7,1.1,1.2,1.6c34.1,36.1,68.2,72.3,102.2,108.4C180.9,250.3,190.5,240.6,184.5,234.2z"/></g></g></svg>
  """
}

func script(_ day: Int) -> String {
  """
  <script type="text/javascript">
      let currentWebsiteIndex = \(day);
      document.addEventListener('keydown', function(event) {
          if (event.key === 'ArrowLeft') {
              currentWebsiteIndex = (currentWebsiteIndex - 1 + 365) % 365;
              window.location.href = currentWebsiteIndex;
          } else if (event.key === 'ArrowRight') {
              currentWebsiteIndex = (currentWebsiteIndex + 1) % 365;
              window.location.href = currentWebsiteIndex;
          }
      });
      const left = document.getElementsByClassName("left")[0];
      const right = document.getElementsByClassName("right")[0];
      left.addEventListener("click", function(event) {
          currentWebsiteIndex = (currentWebsiteIndex - 1 + 365) % 365;
          window.location.href = currentWebsiteIndex;
      });
      right.addEventListener("click", function(event) {
          currentWebsiteIndex = (currentWebsiteIndex + 1) % 365;
          window.location.href = currentWebsiteIndex;
      });
  </script>
  <style>
  body { 
    max-width: max-content; margin: auto;
  }
  @media (prefers-color-scheme: dark) { 
    table { color: white; }
  }
  h1 {
    position: absolute; top: 0; left: 50%;
    transform: translate(-50%, 0);
    font-size: 55px;
  }
  div {
    position: absolute;
    top: 50%;
    transform: translate(-50%, -50%);
  }
  table {
    font-family: monospace; 
    border-collapse: collapse; width: 1573px; table-layout: fixed;
  }
  th { border: 2px solid white; text-align: right; padding: 5px; }
  td { border: 2px solid white; text-align: left; padding: 5px; }
  svg.right {
    transform: scale(-1,1); width: 128px; position: absolute; top: 0; right: 0;
  }
  svg.left {
    width: 128px; position: absolute; top: 0; left: 0; 
  }
  svg:hover { fill: white; }
  </style>
  """
}
