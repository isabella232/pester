require "rails_helper"

feature "User views PRs" do
  scenario "Sees all open Pull Requests" do
    create(:pull_request, title: "Implement Stuff")
    create(:pull_request, title: "Design Stuff")

    visit root_path

    expect(page).to have_content("Implement Stuff")
    expect(page).to have_content("Design Stuff")
  end

  scenario "Sees link to PR on Github" do
    create(:pull_request, title: "Implement Stuff", github_url: "https://github.com/thoughtbot/pester/pulls/1")

    visit root_path

    expect(page).to have_link("Implement Stuff", href: "https://github.com/thoughtbot/pester/pulls/1")
  end

  scenario "Sees link to repo on Github" do
    create(:pull_request, repo_name: "thoughtbot/pester", repo_github_url: "https://github.com/thoughtbot/pester")

    visit root_path

    expect(page).to have_link("thoughtbot/pester", href: "https://github.com/thoughtbot/pester")
  end

  scenario "Sees metadata" do
    create(
      :pull_request,
       created_at: 1.hour.ago,
       user_name: "JoelQ",
       user_github_url: "https://github.com/joelq",
       github_url: "https://github.com/org/repo/pulls/123",
       avatar_url: "http://myavatar.com",
       comment_count: 3,
    )

    visit root_path

    expect(page).to have_content("#123 opened about 1 hour ago by JoelQ")
    expect(page).to have_link("JoelQ", href: "https://github.com/joelq")
    expect(page).to have_avatar("http://myavatar.com")
    expect(page).to have_selector("[data-role='comment-count']", text: "3")
  end

  scenario "viewing tags for the current pr" do
    create(
      :pull_request,
      tags: [tag("rails"), tag("ember")],
    )

    visit root_path

    expect(page).to have_tag("rails")
    expect(page).to have_tag("ember")
  end

  scenario "Does not see completed PRs" do
    create(:pull_request, title: "Implement Stuff", status: "needs review")
    create(:pull_request, title: "Review Stuff", status: "in progress")
    create(:pull_request, title: "Design Stuff", status: "completed")

    visit root_path

    expect(page).to have_content("Implement Stuff")
    expect(page).to have_content("Review Stuff")
    expect(page).not_to have_content("Design Stuff")
  end

  scenario "Sees tags with active pull requests" do
    rails = tag("rails")
    ember = tag("ember")
    create(
      :pull_request,
      title: "An Ember PR",
      tags: [ember],
      status: "completed"
    )
    create(
      :pull_request,
      title: "A Rails PR",
      tags: [rails],
      status: "needs review"
    )

    visit root_path

    within(".tags") do
      expect(page).to have_content("rails")
      expect(page).not_to have_content("ember")
      expect(page).to have_selector("[data-role='pr-count']", text: "1")
    end
  end

  scenario "Can filter by tags" do
    create_pull_requests_with_tags

    visit root_path
    within(".tags") do
      click_on "ember"
    end

    expect(page).to have_content("An Ember PR")
    expect(page).not_to have_content("A Rails PR")
    expect(page).to have_content("A long pr")
  end

  scenario "Can filter by multiple tags" do
    create_pull_requests_with_tags

    visit root_path(tags: "ember")
    within(".tags") do
      click_on "rails"
    end

    expect(page).to have_content("An Ember PR", count: 1)
    expect(page).to have_content("A Rails PR", count: 1)
    expect(page).to have_content("A long pr", count: 1)
  end

  scenario "Can remove a tag from filtered tags" do
    create_pull_requests_with_tags

    visit root_path(tags: "ember,rails")
    within(".tags") do
      click_on "ember"
    end

    expect(page).not_to have_content("An Ember PR")
    expect(page).to have_content("A Rails PR")
    expect(page).to have_content("A long pr")
  end

  private

  def create_pull_requests_with_tags
    ember = tag("ember")
    rails = tag("rails")
    create(:pull_request, title: "An Ember PR", tags: [ember])
    create(:pull_request, title: "A Rails PR", tags: [rails])
    create(:pull_request, title: "A long pr", tags: [rails, ember])
  end

  def have_avatar(url)
    have_css("img[src='#{url}']")
  end

  def have_tag(tag_name)
    have_css("[data-role='tag']", text: tag_name)
  end

  def tag(name)
    create(:tag, name: name)
  end
end
