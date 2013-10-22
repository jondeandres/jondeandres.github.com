---
layout: post
title: Synchronize Javascript in Capybara 2
---
In a project i'm working on i'm migrating our old integration specs
with Capybara 1 to use Capybara 2. The last version of Capybara makes
you to write better integration specs cause is more strict with the CSS
selectors and content you use to find elements.

The big changes with Capybara 1 can be found
[here](http://techblog.fundinggates.com/blog/2012/08/capybara-2-0-upgrade-guide/).
The important change i'll talk about is about the missing `wait_until`
method we had in Capybara 1. It doesn't exist any more in Capybara.

If we need to wait for an element to appear in the DOM cause of an
AJAX request we can use matchers like `have_css`, `have_selector` or
`have_content`. They'll wait a time for the element to appear. This
time by default is 2 seconds but you can change it just setting
`Capybara.default_wait_time`.

Ok, this is the way to wait for the elements to appear in the DOM, but what we'd like it's to
wait for the result of evaluating some Javascript statement. This is a
little more complex and it seems that Capybara doens't treat this
case.

We want to evaluate `$.active` and check if the return value is 0.
The matcher methods i've talked before use all of them the method
`synchronize` of Capybara. We can take a look to this method:

{% highlight ruby %}
{% include ruby/synchronize.rb %}
{% endhighlight %}

This method yields the block you pass and rescues any exception raised
in the block. It will re-raises the exception unless some condition
avoid it and then the block will be retried. The condition we are
interested in is this one:

{% highlight ruby %}
raise e unless catch_error?(e)
{% endhighlight %}

And `catch_error?` method is like this:

{% highlight ruby %}
{% include ruby/catch_error.rb %}
{% endhighlight %}

So `synchronize` doens't re-raises the exception if it's one of the
driver's `invalid_element_errors` or `Capybara::ElementNotFound`. The
`invalid_element_errors` is defined by the driver and depending on the
kind of driver you are using (Poltergeist, Selenium, Webkit) you will
need perhaps to monkeypatch the driver.

We can use `Capybara::ElementNotFound` or a class inheriting of it to
control the exception raising in the block we want to synchronize. So a way to
wait for a expected result in Javascript could have this implementation:

{% highlight ruby %}
page.document.synchronize do
  page.evaluate_script('$.active') == 0 or raise Capybara::ElementNotFound
end
{% endhighlight %}

