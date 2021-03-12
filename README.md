# PotatoBeans SPA Framework

The PotatoBeans SPA framework is created to ease the development of a web
application, while still retaining the vanilla HTML/CSS development workflow.
Nowadays, as JavaScript frameworks continue to grow, we see less people develop
a website using just pure HTML/CSS. People start to use reusable components,
and then reusable design, which make the design of a web feels industrialized.

When using reusable components, in HTML/CSS world, because an HTML element (tag)
can have so many CSS properties, we end up overriding many of those CSS properties
especially when the web design is complex. This happens using bootstrap, a
mostly CSS framework. Creating columns is easy, until the design requires complex
column design, we then start to override almost all styles created by bootstrap.
If that's the case then why not throw bootstrap away completely?

Because PotatoBeans never create a design that is industrialized (too common),
and tailor each design to a specific need and style, PotatoBeans web design will
never be not complex. The [potatobeans.id](https://potatobeans.id) website for
example, use PowerPoint like slide design. This way we cannot just use `bootstrap`
as we require even more CSS properties and media queries to control elements
so that they fit in one view as there is no infinite vertical scroll. Also
needed are animations that are built into many elements in the design, which makes
it harder to use frameworks that do not support animations. We need
custom-built elements and animations, almost all the time, but we still want to
reuse components, and reduce overheads and write clean codes. JavaScript frameworks
can achieve some of the points that we want.

## Philosophy

The PotatoBeans SPA framework was created so that we can use Dart cleanly for
the web.

### Why Use Dart

Because we want to write clean code that is consistent and easy to read, we know
that using pure JavaScript is not an option. This immediately throws jQuery away,
although jQuery actually solves some of our problems. It provides a decent animation
library, and do not introduce the need of too many industrialized components. It
is not a framework, but a library. Because jQuery is so old we do not bother to
look at it again anyway.

TypeScript is an alternative. React and other frameworks are available in TypeScript.
However, TypeScript still feels like JavaScript. It helps at some point but writing
TypeScript in most cases still feels like writing JavaScript, only stricter.

Dart on the other hand, provide a powerful feature: OOP. TypeScript already
enhances the OOP capability of JavaScript, which is near non-exsistent, but Dart
takes it even further and makes it feel like writing Java, which is consistent
and strict. However, it does not make it feel like writing verbose codes, like
Java, as it also supports some dynamic features JavaScript and other dynamic
languages have. Therefore, it sits in the middle, providing benefits and best
of both worlds. Unfortunately, during the first time we use Dart for web, which
is 2018 for BIST League, the only framework available was AngularDart.

### Why not React, Vue, Angular, and so on

There are like, maybe, hundreds of JavaScript frameworks these days. They all
offer too many overlapping features, which makes them harder to choose from.
However, even using those frameworks we still are obligated to write HTML/CSS
when we want to use custom components. It does not make too much difference in
writing, only the style is different. In the end we can go back to the old,
SSR (Server-side Rendering) days where we create a lot of HTML pages and
CSS files. In the end it's still writing HTML and the corresponding CSS styles.
Those frameworks however, have some other features like local storage, routers,
MVC or MVVM mindset, and so on. React for example utilizes PopStateEvent to
implement SPA routing so that you can change the URL without reloading the page.
This is probably the only way to do this, so all frameworks may also use this way,
including PotatoBeans SPA framework.

Because the W3C and so many people continually enhance the capability of
browser JavaScript, and Chrome and Mozilla have dominated the browser world,
frameworks continue to follow their specifications. Browsers already provide a
powerful way to manipulate HTML and CSS, which actually makes jQuery quite
deprecated. The introduction of native `querySelector` *kinda* killed jQuery.
Browser native DOM manipulation functions have become so powerful that we can
actually make a complete web application without the help of any frameworks.
However, it's a user interface that we are interacting with, using just low-level
functions will create horrible codes. That is why frameworks like Electron, Qt,
Java Swing, exists, to prevent you from writing bad frontend codes.

Dart itself actually enhances the capability of native browser functions by
adding some nice wrapper functions and classes. This further reduces the need of
frameworks like AngularDart or React.js (that can't be used as it is not
available in Dart, attempts have been made to port it to Dart though).

### Why Bother Creating a Framework

PotatoBeans SPA framework was not created to become a framework. It evolved from
reusing codes when we tried to create a web application using pure Dart. We
reuse codes and create libraries and abstractions, continue adding things. The
framework was born in BIST League 2018 project, was enhanced a lot with inspirations
from Flutter in ABSIS (2019), and was then production-ready in potatobeans.id (2020).
It is enhanced even more with some more breaking changes in Capio project (2020).

Because it was built from pure reusing codes (clean code) mindset, it is not
designed to compete with other frameworks. It is designed to keep PotatoBeans
frontend developers to write clean codes that follow many PotatoBeans cultures
and conventions. It is designed to be simple and light, without too much overhead
while still retaining the old pure HTML/CSS mindset. You create components by
writing HTML/CSS like you used to be. Those components can be reused
and controlled consistently. The PotatoBeans SPA framework also
adds animation support, using CSS3 animations, which does not exist if we were
to use pure Dart. Animation was the main driver of why this framework was born
out of pure Dart for web. Animations were great using jQuery but not available in Dart.

jQuery shaped the web. Many of jQuery features were eventually absorbed into
the body of W3C specifications and become native in many frameworks. Animations
unfortunately were not part of that. An effort to create reliable animation exists,
but so far it's only available in Chrome, using WebAnimation API. That is why
we create animations by using wrapper codes of CSS3 transitions. It feels like a hack,
it is actually, but it's reliable and works in almost all modern browsers.

## Architecture

There are three main parts of the framework: component, animation, and router.

### Component

The `Component` base class is the main building block of the web application
written using PotatoBeans SPA framework. Unlike in other frameworks, `Component`
is not a widget. You don't just compose Component on top of other Component.
Component is just an abstraction of a bunch of HTML codes, grouped together so
that they can be reused and controlled consistently. Using Components, you
can control an HTML page OOP-way, which hopefully makes it easier and cleaner.

There are two types of Component: `RenderComponent` and `StringComponent`.
In previous versions (ABSIS and potatobeans.id), `RenderComponent` is split
into two: `StatelessComponent` and `StatefulComponent`, which no longer exist.

*Each component stores a small version of HTML DOM.* It contains a DOM which
contains a tree of HTML tags. It can be manipulated, like you can have the
`<div>` element inside a component have its `display` CSS property be changed, even
before the component was rendered. They are represented by `Element` class,
a native JavaScript class that is also available in Dart. A `<div>` tag is
represented by a `DivElement`, an `<a>` tag is represented by an `AnchorElement`,
and so on. Component stores a tree that is composed of these `Element` classes.

#### RenderComponent

RenderComponent is a wrapper class for HTML codes which need to be rendered
directly on the page. HTML tags inside this components can be rendered directly
using `renderTo` method, and can be unrendered using `unrenderTo`. Although
you are not intended to use these methods, a Router is sometimes used to render them.

The basic of all Component, including RenderComponent, are `id` and `baseInnerHtml` properties.
They will be explained shortly.

To create a RenderComponent, create a class that extends the `RenderComponent` class.

```dart
// MyComponent.dart
class MyComponent extends RenderComponent {
  MyComponent(String id) : super.empty(id) {
    baseInnerHtml = '''
    <div id="$id">Hello world!</div>
    ''';
  }

  @override
  void loadEventHandlers() {
  
  }
}
``` 

By convention, you create a RenderComponent in a separate file, just like
creating a Java class.


#### StringComponent

StringComponent is a wrapper class for HTML codes which need to be included
in other RenderComponent. You can say that a RenderComponent is composed of
many StringComponents. You can also compose a StringComponent with other
StringComponents, but this is sometimes not necessary and should be avoided
unless really needed. The reason behind this is because a StringComponent
requires a valid RenderComponent as parent. It does not have to be direct
parent though. A StringComponent must always be contained inside a RenderComponent,
for it to be rendered together to the DOM.

To create a StringComponent, create a class that extends the `StringComponent` class.

```dart
class MyStringComponent extends StringComponent {
  MyStringComponent(RenderComponent parent, String id) : super.empty(parent, id) {
    baseInnerHtml = '''
    <div id="$id"></div>
    ''';

    @override
    void onComponentAttached() {
    
    }
  }
}
```

Unless quite large, the StringComponent does not need to be in its own file.

The StringComponent needs a reference to its parent RenderComponent so that when
the RenderComponent is rendered, the StringComponent is attached to it and gets
rendered too. For this reason, the StringComponent has `onComponentAttached` method
that is called when the StringComponent is attached to the RenderComponent.

##### What Does it Mean by Attached to RenderComponent

Because Component stores string HTML codes as `Element`, there still needs a time
when the Component converts developer-defined HTML strings into a mini-DOM
represented by a collection of `Element`. This is done automatically when you
fill `baseInnerHtml` for RenderComponent, but not for StringComponent. This
behavior may change in the future, but in order so that a StringComponent can
be manipulated by the parent RenderComponent, the StringComponent DOM representation
needs to be attached to the RenderComponent mini-DOM. In other words, a tree
of `Element` classes in StringComponent needs to be moved together into a tree
of `Element` classes in its parent RenderComponent. This is why it needs to be
attached manually, originally.

This behavior have changed however, with the introduction of `parent` parameter
in the constructor. The parent will now attach all their children StringComponents
when the parent `baseInnerHtml` is edited.

*Before the component is attached, `elem` is null*. See about `elem` in `baseInnerElement`
section.

#### The `id` Parameter

To create a Component, you will need an `id`. An `id` is identical to a HTML
`id` attribute, therefore it must be unique. Another rule when creating a
Component is to also put the id in the outermost HTML tag that you define
in `baseInnerHtml`. Looking at the `MyComponent` example above, the `<div>` tag
has `id="$id"` attribute. This is needed, as of today. Later on in the future
the id may no longer be needed and can be replaced with a unique random ID or hash.

The id is needed to uniquely identify and select the component through DOM.

#### The `baseInnerHtml` Parameter

The `baseInnerHtml` parameter is used to create a DOM for the Component to store.
You create a component by writing a string of HTML tags in here. It supports complete
HTML and CSS syntax, just like writing in an HTML file.

To create the style for your component, just add classes to your component and
create a style on a separate CSS file.

#### The `baseInnerElement` Parameter and `queryById()` Method

The lesser use `baseInnerElement` parameter is used to store the DOM representation
of the `baseInnerHtml`, in form of `Element`s. You do not usually manipulate it
directly, and it cannot be accessed directly. It is used to do querySelector upon,
to select some elements. To do that, you can use `queryById` (and other methods in the future)
to select an element from the tree. It is a shortcut of `elem.querySelector('#$id')`.

The `elem` parameter is used to fetch `baseInnerElement`, for querySelector. When
you do `elem.querySelector`, done using `queryById` for example, you can select
an element from the tree based on the selector. This way, using queryById, you can
find an element of a certain ID which is contained in the component. This is
the only way you can select subelements in a RenderComponent or StringComponent,
if you wish to create an animation or create an event handler.

*In StringComponent, `elem` is null until the element is attached.* You can
use `queryById` or other variants involving `elem` at `onComponentAttached` or
`loadEventHandler`.

#### Rendering Steps of RenderComponent

When a RenderComponent gets rendered, using `renderTo` or some other methods
like `renderPrepend`, some methods are executed. The order are as follows:

```text
preRender
renderTo
postRender
preUnrender
unrenderFrom
postUnrender
```

The `postRender` and `preRender` are special, because `loadEventHandlers` is
called after render (on `postRender`), and `unloadEventHandlers` is called
before unrender (on `preUnrender`). They are called this way so that event
handlers are active only when a component is rendered. Read about them in
*Event Handling* section.

Do not run a long running task in `preRender`, although preRender actually
returns a Future. They are designed usually to do some UI positioning and setup,
and is lesser used than postRender. The same goes for `postUnrender`. A long
running `preRender` will cause the UI to look like hanging.

#### Event Handling

Currently, the RenderComponent and StringComponent uses `MEventHandler` mixin,
which gives them the ability to store event handler subscriptions. The mixin
introduces two methods, `loadEventHandlers` and `unloadEventHandlers`. They are
used to load event handlers, for example by doing `onClick.listen` on a certain
element. This is because `loadEventHandlers` is called in `postRender`, used
to attach those event listeners to the DOM. Although you can actually load event
handlers on an unrendered component, it is better to do it after so that event
handlers do not listen on a component that users cannot interact with.

To load events, use event handling method like `addOnClickTo` (and others in the future)
to add onClick event to an `Element`. Event handling uses a wrapper function due
to the fact that the doing `onClick.listen` returns a `StreamSubscription` object,
which needs to be cancelled by calling `cancel` when you want to destroy the
event listener and prevent memory from leaking. To do that automatically, you
can use such wrapper method like `addOnClickTo` so that the Component can store
the resulting StreamSubscription and cancel them all during `unloadEventHandlers`.

To create an event, follow this example

```dart
// MyComponent.dart
class MyComponent extends RenderComponent {
  MyComponent(String id) : super.empty(id) {
    baseInnerHtml = '''
    <div id="$id">
        <button id="$id-button">Test</button>
    </div>
    ''';
  }

  @override
  void loadEventHandlers() {
    addOnClickTo(queryById('$id-button'), (event) {
      event.preventDefault();
      print('this is executed when $id-button is clicked');
    });
  }
}
```

The example above shows a button with ID '$id-button'. It's a good idea to
name subelements with ID that has prefix of the component ID. This ensures that
all HTML tags in the application have unique ID. The component stores somewhere
a StreamSubscription of the onClick listener created. When the component itself
calls `unloadEventHandlers`, during `postUnrender`, it will cancel the
StreamSubscription for you, preventing memory leak.

In the previous versions, the developer of the component is responsible for
storing SteamSubscription and manually cancelling it, by overriding
`unloadEventHandlers` and calling cancel. This can still be achieved by
calling `onClick.listen` manually which will return a `StreamSubscription<MouseEvent>`
class. The object can be stored as the component attribute and cancelled in
`unloadEventHandlers`, if you do not want the component to cancel it automatically for you.

Event handling works for other events as well, such as `onDoubleClick`.

##### StreamSubscription

StreamSubscription is a generic class. It's native in Dart. It represents your
subscription to an event, for example onClick of an element. The only method
that you usually use is `cancel()`, which will stop the onClick event to call
the registered callback function.

`onClick.listen` will return `StreamSubscription<MouseEvent>` type.

##### Waypoint

Waypoint is a new library implemented to detect if an element is displayed on
screen. Waypoint works by continuously checking whether an element is displayed
on screen by tracking its position relative to a viewport. The name `waypoint`
came from the same jQuery waypoint functionality.

To use waypoint, add your component and a handler function to the constructor,
and an optional offset value.

```dart
waypoint = new Waypoint(queryById('some-element-id'), () {
  // Do something when the element come to view 
});

waypoint.loadEventHandler();
```

To initialize waypoint, call waypoint `loadEventHandler()` function to register
waypoint internal `onScroll` listener. You call it naturally in your component
`loadEventHandlers()`.

To dispose waypoint event listener, which
will release the memory that it uses to prevent memory leak, call `unloadEventHandler()`
method in your component `unloadEventHandlers()`.

Waypoint is useful for example to trigger an animation to display the element itself.
This is useful only for animations that do not involve unrendered components, for
example `CustomAnimation.displayFadeIn` (explained shortly), which will change
the element `display` from `none` to something else. When the element is using
`none` as the `display` parameter, the component has no height/width, which
makes waypoint not working properly.

###### How Waypoint Works

Waypoint works by registering an `document.onScroll` event listener. When a
scroll event is triggered, which is multiple times in a row during scrolling,
waypoint will check the element position on screen. The position is retrieved
using `Element.getBoundingClientRect()`
([MDN](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect)).
The function returns 4 values, `top`, `left`, `width`, `height`. To make waypoint
works with vertical scroll, we look at the element `top` and `height` values. Please
read the MDN documentation to know the detail of these parameters.

The `top` value basically indicates the distance between the top left point
of the element to the current viewport position. That means, the more the user
scrolls down the page, the `top` value decreases. We can then check if the
`top` value eventually becomes <= than the viewport height to see if the
element is finally shown in the viewport.

###### Waypoint `offset`

Read more about this in `Waypoint` class documentation.

### Animation

The animation is introduced to help creating an animation over an element. It
resolves in the `CustomAnimation` class.

#### CustomAnimation

The `CustomAnimation` class is an animation controller to control an animation
of an element. To play an animation forward, use `play()`. To rewind the
animation, use `rewind()`.

```dart
CustomAnimation(Element element,
      Map<String, String> from,
      Map<String, String> to,
      Duration duration,
      {Map<String, String> prePlay,
        Map<String, String> postPlay,
        Map<String, String> preRewind,
        Map<String, String> postRewind}) {
        
}
```

You supply an HTML element that you receive from `elem` or `queryById` (and other
query variants). The `from` is a map of CSS properties, which will be set
to the element before it is played. The `to` parameter is a map of CSS properties,
which will be set to the element after it has done playing (before rewind).
You can then create such maps to animate the element from opacity 0 to 1.

```
// from
{'opacity': '0'}

// to
{'opacity': '1'}
```

The `duration` parameter is straightforward, it accepts a `Duration` object which
dictates how long the animation will run. `CustomAnimation` currently does not
accept easing options.

The `prePlay`, `postPlay`, `preRewind`, and `postRewind` are properties which
are set to the element before play, after play, before rewind, and
immediately after rewind. The `prePlay` for example is useful to set the component
`display` from `none` to something else, probably to fade in the element. The
`postRewind` can be used for the same thing, by setting the `display` to `none`
so that when an element fade in animation has been rewound, the display is set
to `none` so that the element is visually unrendered from the browser.

To create a CustomAnimation, follow this example.

```dart
var animation = CustomAnimation(queryById('someid'), 
  {'left': '-30px'},
  {'left': '0'},
  Duration(millisecond: 200)
);

animation.init();
```

After creating an animation, you need to initialize it by calling `init()`. This
will set initial CSS properties to the element. Because of this, *you need to make
sure that the component has been attached when using a `StringComponent`.* You can
do this by creating `CustomAnimation` and `init()` under `onComponentAttached()`.

```dart
CustomAnimation _animation;

@override
void onComponentAttached() {
  _animaton = CustomAnimation.fadeIn(queryById('$id-button'), Duration(milisecond: 200))
    ..init();
}
```

To start/rewind the animation, you can do
```dart
await animation.play();
await animation.rewind();
```

`play()` and `rewind()` return `Future<void>`, which you can use by calling
`then()` or using `await` (`async`/`await` is preferred).

Instead of creating a CustomAnimation your own, try to use the shortcut by using
some named constructors like `CustomAnimation.displayFadeIn` and others (see CustomAnimation.dart).
Using such shortcut constructors you do not need to define your own `from` and `to`
state properties, and you just need to supply the element and duration.

#### Animation Queue (`MAnimationQueue`)

The `MAnimationQueue` mixin provides a component with animation queue. The animation
queue is created since the potatobeans.id project. Many of potatobeans.id components
require a queue of animations to animate each "slide" of the web. This involve
animating a lot of element in sequence, or simultaneously. To help with this,
we introduced `MAnimationQueue` (`MAnimation` in previous versions).

An animation queue is just a queue of `AnimationElement`, which is parent of
`CustomAnimation` and `CustomAnimationDelay` (and the deprecated `CustomAnimationMultipler`).
To add an AnimationElement, whether it's a real animation or just a delay in the
queue, you can use

```text
addSingleAnimation() // Add a single animation to the queue
addSimultaneousAnimations() // Add a set of animations that will be played simultaneously
addAnimationDelay() // Add a delay in the queue (in the form of CustomAnimationDelay)
```

Let's say you have CustomAnimation `A`, `B`, `C`, and `D`. You want to play
those animations in this order: `A` -> `B` and `C` together -> delay -> `D`. To
do that, just do
```dart
addSingleAnimation(A);
addSimultaneousAnimations([B, C]);
addAnimationDelay(Duration(milisecond: 200)); // Delay as Duration object
addSingleAnimation(D);
```

Just like creating CustomAnimation manually, you need to initialize them. To do
this, you can just call

```dart
initAnimations();
```

which will initialize all animations in the queue for you.

To play your animation queue, there are two options, playing the queue
sequentially, like a normal queue, or overriding the queue and playing all
animations simultaneously. Use these methods to play your animations.

```dart
playAnimationSequential(); // Play the queue sequentially like a normal queue
playAnimationSimultaneous(); // Override the queueing behavior and play everything simultaneously

// Rewinding
rewindAnimationSequential();
rewindAnimationSimultaneous();
```

Those methods return a Future object which waits until all animation to finish.


### Router

The router, like a controller, holds what is called a routing table. The routing
table is a set of rules or a function that tells the router to render a certain
`RenderComponent` over an element when the routing table matches. Currently
there is only one type or Router, which is `UrlComponentRouter`, which renders
the component based on the URL. This is what makes SPA work.

To use a Router, you need to give it what is called `routerElementBind`. `routerElementBind`
is a HTML ID, used to point in which HTML element the router is acting. *The router
replaces the content of the HTML element pointed by `routerElementBind` based on
the routing table.* If you give it an element with ID `test`, then the HTML
element with ID test will have its content be controlled by the router. In this
case if it's the UrlComponentRouter, it will have the content changed based on
the current URL.

All routers interact with `Route` object, which contains the `RenderComponent`
to render, and other additional parameters explained shortly.

#### Routing Based on URL Using `UrlComponentRouter`

An SPA and a conventional web application differ in the way they render web pages.
In SPA, the browser no longer reloads and downloads new pages everything the user
chooses to change page, for example by clicking a link. In SPA, the web is designed
like a mobile application. Click another menu should not reload the whole page,
but just a portion of the page. This way, only one HTML page needs to be loaded
at a time to render the whole application. The router just replaces some parts
of the page with some other elements, depending on user interaction. `UrlComponentRouter`
makes this possible.

`UrlComponentRouter` listens to what is called `PopStateEvent`. This event is a
native browser event that is fired everytime the browser history is changed, for
example when the user clicks on the back/forward button. When a user clicks on back/forward
button, the browser will change the URL in the address bar, and `UrlComponentRouter`,
listening to `PopStateEvent`, can replace some parts of the page with a new
component, according to the routing table that has been setup in the router.

The problem with this is, clicking a link (for example an `<a href="/anotherpage">`),
does not trigger `PopStateEvent`. The default behavior of clicking a link is
to reload a new page pointed by `/anotherpage`. For the router to work, developer
is obliged to register an `onClick` handler (by using `addOnClickTo`) over elements
like `<a>` or `<button>` and do `event.preventDefault()` to prevent this from happening.
The next step is to emit an artificial PopStateEvent that will be listened by the
router.

##### Emitting a `PopStateEvent`

Suppose that you have this component (extending from the `MyComponent` example above).

```dart
// MyComponent.dart
class MyComponent extends RenderComponent {
  MyComponent(String id) : super.empty(id) {
    baseInnerHtml = '''
    <div id="$id">
        <button id="$id-button">Test</button>
    </div>
    ''';
  }

  @override
  void loadEventHandlers() {
    addOnClickTo(queryById('$id-button'), (event) {
      // Default behavior is prevented
      event.preventDefault();
    });
  }
}
```

Focus on the `loadEventHandlers` part. In there, we select the `<button>` element
inside the component by using `queryById`, and registers a callback function.
A callback function for onClick event requires a single argument, typically named
`event`, which hold an `Event` object. You mostly do not need to interact with it
except for doing `event.preventDefault()`, which will prevent the default callback action
of the event to happen. You can then proceed to create a PopStateEvent.

To create a `PopStateEvent`, `UrlComponentRouter` have a static helper function
that you can use, `emitPopState(url)`. It accepts a single String argument, which
is a URL. Calling `emitPopState('/anotherpage');` will do:
1. It will create a new page history item in the browser. The user
   can then click back on the browser to go back to previous URL. It is done by
   using `history.pushState` function, native to the browser. Because of this a
   new history item is added and the URL in the browser address bar will change
2. Throw a PopStateEvent with URL set to `/anotherpage`
3. All active `UrlComponentRouter`s will listen to that event and see if it matches a certain *pattern*
4. If it matches, the router will check its routing table
5. The router renders a new component on HTML element pointed by `routerElementBind`

##### The `UrlComponentRouter` `urlPattern`

The constructor of `UrlComponentRouter`accepts two parameters, `urlPattern`, which
is a string with certain syntax, and the `routerElementBind`. The `urlPattern` is
a string which contains a pattern for the router to match with the current URL.
Currently, it accepts a placeholder and a normal URL format. Consider this pattern

```text
/[page]
```

The router will then matches all URL like `/home`, `/test`, `/dkjdkejlakj` and so on
but not `/home/test`. The `[page]` placeholder causes the router to look at an
arbitrary string. The placeholder needs to be:
1. In lowercase string
2. Starts with `[` and ends with `]`
3. Cannot contains symbol, only regex `[a-z]`

You can add many more placeholder, separated with `/`. The pattern

```text
/[page]/[sub]
```

will match `/home/test`, `/abhds/skjde`, and `/test/home` but not `/test`, `/test/test/test`,
and so on.

If the pattern ends with `/`, that means it will do a prefix match. The
pattern

```text
/[page]/
```

will match `/home/test` and `/home`, but not `/`. You can also add an exact
match URL in the pattern, like so

```text
/home/[sub]
```

which will match `/home/test`, but not `/test/home`, `/home`, and so on.

The placeholder is used to match with the routing table. Although the router
match the pattern with the URL, the router does not stop there. It calls the
`routeTableMatcher` function to further match the parameter to render the
component.

If the router pattern does not match the URL, it will do nothing, not event
unrendering the current rendered component.

##### The `routeTableMatcher` Function

`UrlComponentRouter` do not use a map as its routing table, but a function.
The function signature is

```dart
Route Function(Map<String, String> urlParams);
```

A `RouteTableMatcher` function is a function that returns a `Route` object,
indicating the chosen route. It accepts a parameter, a map, which contains
the parameter extracted from the placeholders that you place in the pattern.
See this example.

```text
// Pattern
/home/[page]/[sub]/

// URL
/home/test/test1   ==> does not match pattern, ignored
/home/test/test1/a ==> {page: test, sub: test1}
/home/test1/a/b    ==> {page: test1, sub: a}
```

**This behavior is still experimental and will be revised in the future.**

In the `RouteTableMatcher` function that you create, you can then choose to
return a `Route` based on how you match the parameters. For example:

```dart
Route myMatcher(Map<String, String> params) {
  if (params['page'] == 'test' && params['sub'] == 'a') {
    return Route(...); // Return a component
  } else {
    return Route(...); // Return other component
  }
}
```

You can also return `null`, which tells the router to ignore the URL and does not
do anything.

##### The `Route` Class

A `Route` indicates a RenderComponent to render and some additional actions that happen
pre/post render/unrender. The `Route` takes a mandatory RenderComponent argument
and 4 optional arguments which are functions. Please look at the constructor
at `router/Route.dart` for details.

The `beforeRender` and `beforeUnrender` is a function with this signature:

```dart
Future<bool> Function();
```

These functions must return a boolean (in the form of a Future). The boolean
value is used by the router to decide whether to continue rendering or unrendering
the component. If you give it `false` value then it will stop rendering the component,
and does not fire the `afterRender` or `afterUnrender` function.

The `beforeRender` for example is useful for changing the document title, especially
when used with the uppermost router (the router that sits in the root component, or
the main component as you may call it, which is usually defined in main.dart). The
root/uppermost router is used usually to change a large portion of the page, which
gives the illusion of the page changing to the user. This usually involves changing
the title of the browser page.

```dart
Future<bool> myBeforeRenderFunc() {
  document.title = 'my title';
  return Future.value(true);
}
```

The `afterRender` and `afterUnrender` signatures are like the before counterparts,
but do not return any values (`Future<void>`).

###### The Route `id`

The route ID for this route, must be unique, and needs
to be unique just for the router where the `Route` is registered.
It is used to check whether the currently rendered route is the same
with newly rendered Route. If a new request to render a route is given,
and the route has the same id as the currently rendered route, router is
intended to do nothing.

It's a good practice to fill it a unique name that describes the component being
rendered like the URL for the component. For the order page, you can give it
for example `/order` or `/order/` if the component holds another router inside,
as long as the same component is always given the same ID so that the same
component won't be rendered twice even if it's given twice in the `RouteTableMatcher`
function.

###### Lazily Loading a Component

**The `Route` represents a RenderComponent as `FutureOr<RenderComponent>`.** This means
that Route can accept a Future instead of the component itself. There is a good
reason for this. Because the component can be represented by a future instead of
a real component, the router can wait for the component to be available first
before rendering it. The router will execute `beforeRender` function first
and then wait for the component to exists before calling rendering it to `routerElementBind`.

With this model, you can separate your component in a separate library and have it
loaded first before rendering it using the router. See this example.

```dart
import 'package:capio_web/index.dart' deferred as index;
import 'package:capio_web/spa.dart';

...

Route mainRouterMatcher(Map<String, String> urlParams) {
    Future<RenderComponent> createIndexPageComponent() async {
      await index.loadLibrary();
      return index.IndexPageComponent();
    }

    if (urlParams.isEmpty) {
      return Route(createIndexPageComponent());
    }

    return Route(...);
  }
```

In the example above, `IndexPageComponent` is only available in index package,
which will be lazily loaded by the browser (indicated by `deferred` keyword).
We created a wrapper function to wait for the library to be loaded first
before instantiating an `IndexPageComponent`. This wrapper function naturally
should return a `Future`, and the Future object is passed to the `Route`
component. This way, the router will then wait for the Future to complete
and render the component. Currently, this is the only way to lazily load
components and render it on screen.

## Getting Started

Start by importing spa.dart, which contains all the components needed for
the framework to work.

### Creating the HTML Page

No web application can exist without a single `.html` file given to the browser from
the server. A HTML page is needed to load our JavaScript file, including our
CSS files. This is the most basic HTML file that is enough to start our script.

```html
<!DOCTYPE html>
<html>
<head>
    <title>My Website</title>
    <link href="/css/mycss.css" rel="stylesheet" />
    <!-- put other css file links here -->
    <script type="application/javascript" src="/js/main.dart.js" defer="defer"></script>
</head>
<body id="body">
</body>
</html>
```

We will see why we add `id="body"` soon.

This page when given to the browser will load `mycss.css` file and the `main.dart.js`
script, assuming that your JavaScript file is named as such. Our application is
written in Dart but will be compiled to a single JavaScript file.

In an SPA, whatever URL the browser is pointing, usually, the same HTML file
is returned. In SPA, we embrace CSR (Client-side Rendering) mindset where the
client renders all the views of the application. The server just sends a script
like `main.dart.js` which processes all the views and renders them to the screen,
according to the URL.

### Planning Your Routes

Before creating your application, make sure you already have a few design for a
few screens/displays/pages in your application. This way you can think of which
part of the page changes, to give the impression of the page changing. If you
have a common web design, with a header and a body content and a footer, you
may think that the body part of the web is the one that changes, and the
header and footer parts change just a little bit, or maybe even not. This means
that the body part of the application can be attached to a router.

If the whole part of the web changes, you can just attach the whole part of the
application to the router. This means that the topmost component (the root
component, or the main component) content is controlled by the router by
passing its ID to the router as `routerElementBind`.

Let's see this example.

```dart
class MainComponent extends RenderComponent {
  MyHeaderComponent header;

  MainComponent([String id = 'main']) {
    header = MyHeaderComponent(this);

    baseInnerHtml = '''
    <div id="$id" class="$id">
        $header
        <div id="$id-content"></div>
    </div>
    ''';
  }

  @override
  void loadEventHandlers() {}
}

class MyHeaderComponent extends StringComponent {
  MyHeaderComponent(RenderComponent parent, [String id = 'header']) : super.empty(parent, id) {
    baseInnerHtml = '''
    <div id="$id" class="$id">My header</div>
    ''';
  }
}
```

To aid with our design, we create our header as a `StringComponent`. This help
separate the HTML codes and makes it easier to read. The header is then constructed
in the MainComponent constructor and used like in the example. The header is given
a reference to the parent RenderComponent using `this`.

In our scenario, we want the `div` element with ID `$id-content` to be controlled
by a `UrlComponentRouter`, because we want its content to change according to the
URL. To do this, we create a `UrlComponentRouter` and bind it to the div.

```dart
// This assumes that id is always `main`
UrlComponentRouter router = UrlComponentRouter('/[page]/', 'main-content');
```

### Initializing your Router and Root Component

The root component, `MainComponent` in the example above, is a component that
holds all other components in the application. Because it is not controlled by
any routers, you need to render it manually by calling `renderTo`. Therefore,
in your main() function, you can finally instantiate `MainComponent` and call
`renderTo` directly to `<body>`.

Because `renderTo` accepts an ID as parameter, give an ID to your `<body>` element.
The id is typically `body`, but you can choose any name you like. *This behavior
may change in the future*.

```dart
void main() {
  MainComponent().renderTo('body');
}
```

Because a router needs to be initialized, you will need to call the router
`init()` function to let the router renders its first, initial, `Route`. You can
do this in the `postRender` function of the `MainComponent`.

```dart
class MainComponent extends RenderComponent {
  UrlComponentRouter router = UrlComponentRouter('/[page]/', 'main-content');

  ...

  @override
  Future<void> postRender() async {
    await super.postRender();
    await router.init();
  }

  ...
}
```

## Future Improvements

* A generic implementation/architecture of a controller, which exchanges and controls
  a view based on a model (like a router)
* Have `UrlComponentRouter` also to also `/` URL (the root)
* Better and cleaner event handling architecture

## Legal and Acknowledgements

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

This repository was built by:
* Sergio Ryan \[[sergioryan@potatobeans.id](mailto:sergioryan@potatobeans.id)]
* Rika Dewi \[[rikadewi@potatobeans.id](mailto:rikadewi@potatobeans.id)]
* Eka Novendra \[[novendraw@potatobeans.id](mailto:novendraw@potatobeans.id)]
* Stefanus Ardi Mulia \[[stefanusardi@potatobeans.id](mailto:stefanusardi@potatobeans.id)]

Copyright &copy; 2020 PotatoBeans Company (PT Padma Digital Indonesia).  
All rights reserved.
