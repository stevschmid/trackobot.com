module ApplicationHelper

  def profile_page(title, footer_info = {}, &block)
    content_for(:title, title)
    content_tag(:div, class: 'container') do
      [
        render(partial: '/layouts/header'),
        capture(&block),
        render(partial: '/layouts/footer', locals: footer_info)
      ].join.html_safe
    end
  end

  def nav_link(link_text, link_path, root = false, opts = {})
    current = current_page?(link_path)
    current ||= root && current_page?(profile_path)

    class_name = current ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path, opts
    end
  end

  def profile_name(user)
    if user.displayname.present?
      user.displayname
    else
      user.username.gsub(/[0-9-]/, ' ').titleize
    end.strip
  end

  def current_user
    @current_user
  end
end

