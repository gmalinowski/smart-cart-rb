require 'rails_helper'

RSpec.describe Fab::ContainerComponent, type: :component do
  it 'renders items' do
    render_inline(described_class.new) do |component|
      component.with_item(icon: 'plus', path: '/', label: 'Add a new shopping list')
      component.with_item(icon: 'minus', path: '/search', label: 'Search for shopping lists')
    end

    expect(page).to have_css('a', count: 2)
  end
  it 'renders no items when none provided' do
    render_inline(described_class.new)
    expect(page).not_to have_css('a')
  end

  it 'renders correct paths' do
    render_inline(described_class.new) do |component|
      component.with_item(icon: 'plus', path: '/lists/new', label: 'Add')
    end

    expect(page).to have_css('a[href="/lists/new"]')
  end

  it 'renders labels and aria labels' do
    render_inline(described_class.new) do |component|
      component.with_item(icon: 'plus', path: '/', label: 'Add a new shopping list')
    end

    expect(page).to have_css('[aria-label="Add a new shopping list"]')
    expect(page).to have_text('Add a new shopping list')
  end

  it 'renders item btn with passed btn_type' do
    render_inline(described_class.new) do |component|
      component.with_item(icon: 'plus', path: '/', label: 'Add a new shopping list')
      component.with_item(icon: 'minus', path: '/search', label: 'Search for shopping lists', type: :secondary)
    end
    expect(page).to have_css('.btn-primary')
    expect(page).to have_css('.bg-primary')
    expect(page).to have_css('.btn-secondary')
    expect(page).to have_css('.bg-secondary')
  end
end
