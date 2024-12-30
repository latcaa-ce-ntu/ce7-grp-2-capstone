document.addEventListener("DOMContentLoaded", () => {
  const categoriesContainer = document.getElementById("categories");
  const tipsContainer = document.getElementById("tips");
  const tips_section1 = document.getElementById("tips-section1");

  // Initially hide the tips container
  tipsContainer.style.display = "none";

  // Fetch and display categories
  fetch("/api/chronic_disease")
    .then((response) => response.json())
    .then((categories) => {
      console.log("chronic_disease Data:", categories);
      categories.forEach((category) => {
        const card = document.createElement("div");
        card.className = "card";
        card.innerHTML = `<h3>${category.name}</h3><p>${category.description}</p>`;
        card.onclick = () => loadTips(category.content);
        categoriesContainer.appendChild(card);
      });
    });

  // Fetch and display tips for a chronic disease
  const loadTips = (contents) => {
    tipsContainer.innerHTML = "";
    tipsContainer.style.display = "none";

    contents.forEach((tip) => {
      const tipElement = document.createElement("div");
      tipElement.className = "tips";
      tipElement.textContent = tip;
      tipsContainer.appendChild(tipElement);
    });

    categoriesContainer.style.display = "flex";
    tipsContainer.style.display = "block";

    tips_section1.scrollIntoView({
      behavior: "smooth",
      block: "start",
    });
  };

  // Fetch and display physical activity data
  fetch("/api/physical_activity")
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then((data) => {
      console.log("Physical Activity Data:", data);
      const list = document.getElementById("phy-activity-list");

      for (const key in data) {
        if (data.hasOwnProperty(key)) {
          const item = data[key];

          const card = document.createElement("div");
          card.className = "activity-card";

          // Add an icon (use font awesome or similar)
          let icon;
          if (item.name.includes("Walking")) {
            icon = "🚶‍♂️";
          } else if (item.name.includes("Jogging")) {
            icon = "🏃‍♂️";
          } else if (item.name.includes("Cycling")) {
            icon = "🚴‍♂️";
          } else if (item.name.includes("Swimming")) {
            icon = "🏊‍♂️";
          } else if (item.name.includes("Yoga")) {
            icon = "🧘‍♂️";
          } else if (item.name.includes("Climbing Stairs")) {
            icon = "🧗";
          } else if (item.name.includes("Pilates")) {
            icon = "🤸‍♀️";
          } else if (item.name.includes("Dancing")) {
            icon = "💃";
          } else if (item.name.includes("Strength Training")) {
            icon = "🏋️‍♂️";
          } else {
            icon = "💪";
          }

          card.innerHTML = `
            <div class="activity-icon">${icon}</div>
            <h3>${item.name}</h3>
            <p>${item.description}</p>
          `;

          list.appendChild(card);
        }
      }
    })
    .catch((error) => {
      console.error("Error fetching data:", error);
    });

  // Fetch and display diet tips data
  fetch("/api/diet_tips")
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then((data) => {
      console.log("Diet tips Data:", data);
      const list = document.getElementById("diet-tips-list");

      for (const key in data) {
        if (data.hasOwnProperty(key)) {
          const item = data[key];

          const listItem = document.createElement("li");

          // Title element
          const title = document.createElement("div");
          title.className = "title";
          title.innerHTML = `${item.name} <span class="chevron">▼</span>`;
          title.addEventListener("click", () => {
            const description = listItem.querySelector(".description");
            const chevron = title.querySelector(".chevron");

            // Toggle visibility
            const isVisible = description.style.display === "block";
            description.style.display = isVisible ? "none" : "block";

            // Rotate chevron
            if (isVisible) {
              chevron.classList.remove("open");
            } else {
              chevron.classList.add("open");
            }
          });

          // Description element
          const description = document.createElement("div");
          description.className = "description";
          description.textContent = item.description;

          // Append title and description
          listItem.appendChild(title);
          listItem.appendChild(description);
          list.appendChild(listItem);
        }
      }
    })
    .catch((error) => {
      console.error("Error fetching data:", error);
    });
});
