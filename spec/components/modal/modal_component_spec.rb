require 'rails_helper'

RSpec.describe Modal::ModalComponent, type: :component do
  it "renders" do
    render_inline(described_class.new(id: "tttt", title: "tttt"))
  end

  it "renders title" do
    render_inline(described_class.new(id: "tttt", title: "tttt"))
    expect(page).to have_text("tttt")
  end

  it "renders close form button" do
    render_inline(described_class.new(id: "tttt", title: "tttt"))
    expect(page).to have_css("form[method='dialog']")
  end

  it "does not render close form button when closable is false" do
    render_inline(described_class.new(id: "tttt", title: "tttt", closable: false))
    expect(page).not_to have_css("form")
  end

  it "renders id" do
    render_inline(described_class.new(id: "tttt", title: "tttt"))
    expect(page).to have_css("#tttt")
  end

  it "renders body" do
    render_inline(described_class.new(id: "tttt", title: "tttt")) do |component|
      component.with_body { "<p>test</p>".html_safe }
    end
    expect(page).to have_css("p", text: "test")
  end

  it "renders actions" do
    actions_html = <<~HTML
      <button class="btn btn-primary">one</button>
      <button class="btn btn-secondary">two</button>
    HTML
    render_inline(described_class.new(id: "tttt", title: "tttt")) do |component|
      component.with_actions { actions_html.html_safe }
    end
    expect(page).to have_css("button", text: "one")
    expect(page).to have_css("button", text: "two")
  end
end
