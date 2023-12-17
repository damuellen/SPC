// SPDX-License-Identifier: Apache-2.0
//
// (C) Copyright 2016 - 2023
// Daniel Müllenborn, TSK Flagsol Engineering

/// Symbols left and right
func icon(_ klass: String) -> String { 
 "<svg version=\"1.1\" class=\"\(klass)\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 256 256\" enable-background=\"new 0 0 256 256\" xml:space=\"preserve\"><g><g><path d=\"M184.5,234.2c-32.9-34.9-65.9-69.9-98.8-104.8c32.7-35.9,65.3-71.7,98-107.6c5.9-6.5-3.7-16.2-9.7-9.7c-34.2,37.5-68.3,75-102.5,112.5c-2.8,3-2.1,6.7-0.1,9.2c0.3,0.6,0.7,1.1,1.2,1.6c34.1,36.1,68.2,72.3,102.2,108.4C180.9,250.3,190.5,240.6,184.5,234.2z\"/></g></g></svg>"
}

func script(_ day: Int, year: Int) -> String { 
  """
  <script type="text/javascript">
      const image = document.getElementById("image");
      const updateimage = () => {
        image.src = "plot.png?day=" + (currentWebsiteIndex + 1);
      }
      let debounceTimer;
      const debounce = (callback, time) => {
        window.clearTimeout(debounceTimer);
        debounceTimer = window.setTimeout(callback, time);
      };
      function dateFromDay(year, day) {
        var date = new Date(year, 0);
        return new Date(date.setDate(day + 1));
      }
      function getDayOfYear(date) {
        var start = new Date(date.getFullYear(), 0, 0);
        var diff = (date - start) + ((start.getTimezoneOffset() - date.getTimezoneOffset()) * 60 * 1000);
        var oneDay = 1000 * 60 * 60 * 24;
        var dayOfYear = Math.floor(diff / oneDay);
        return dayOfYear;
      }
      function getDayOfYearForFirstDayOfMonth(year, month) {
        var firstDayOfMonth = new Date(year, month, 1);
        return getDayOfYear(firstDayOfMonth);
      }
      const date = document.getElementsByTagName('h1')[0];
      let currentWebsiteIndex = \(day - 1);
      let month = dateFromDay(\(year), currentWebsiteIndex).getMonth();
      date.textContent = dateFromDay(\(year), currentWebsiteIndex).toLocaleDateString();
      document.addEventListener('keydown', function(event) {
        if (event.key === 'ArrowLeft') {
          currentWebsiteIndex = (currentWebsiteIndex - 1 + 365) % 365;
          month = dateFromDay(\(year), currentWebsiteIndex).getMonth();
        } else if (event.key === 'ArrowRight') {
          currentWebsiteIndex = (currentWebsiteIndex + 1) % 365;
          month = dateFromDay(\(year), currentWebsiteIndex).getMonth();
        } else if (event.key === 'ArrowUp') {
          month = (month + 1) % 12;
          currentWebsiteIndex = getDayOfYearForFirstDayOfMonth(\(year), month)
        } else if (event.key === 'ArrowDown') {
          month = (month - 1 + 12) % 12;
          currentWebsiteIndex = getDayOfYearForFirstDayOfMonth(\(year), month)
        }
        debounce(updateimage, 250)
        date.textContent = dateFromDay(\(year), currentWebsiteIndex).toLocaleDateString();
      });
      const left = document.getElementsByClassName("left")[0];
      const right = document.getElementsByClassName("right")[0];
      left.addEventListener("click", function(event) {
        currentWebsiteIndex = (currentWebsiteIndex - 1 + 365) % 365;
        month = dateFromDay(\(year), currentWebsiteIndex).getMonth();
        debounce(updateimage, 250)
        date.textContent = dateFromDay(\(year), currentWebsiteIndex).toLocaleDateString();
      });
      right.addEventListener("click", function(event) {
        currentWebsiteIndex = (currentWebsiteIndex + 1) % 365;
        month = dateFromDay(\(year), currentWebsiteIndex + 1).getMonth();
        debounce(updateimage, 250)
        date.textContent = dateFromDay(\(year), currentWebsiteIndex).toLocaleDateString();
      });
  </script>
  """
}

func stylesheets() -> String { 
  """
  <style>
  body {
    height: 100%; max-width: max-content; margin: auto; overflow: hidden;
  }
  h1 {
    position: absolute; top: 0; left: 50%;
    transform: translate(-50%, 0);
  }
  div { 
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
  }
  svg.right { transform: scale(-1,1); width: 128px; }
  svg.left { width: 128px; }
  svg:hover { fill: white; }
  </style>
  """
}
