KMKPython
=========

**KMKPython** is a fork of Adafruit's `CircuitPython
<https://github.com/adafruit/circuitpython>`_ optimized for usage with the `KMK
Firmware project <https://github.com/KMKfw/kmk_firmware>`_ on mechanical
keyboards. The differences are largely related to optimizing bundle size and
building in useful libraries (Bluetooth, OLED, etc.). Adafruit does not endorse
or support KMKPython - please reach out to the KMK dev team before filing
upstream bugs! We can be reached in the issue tracker on Github, or `on Matrix
at #kmkfw:klar.sh <https://matrix.to/#/#kmkfw:klar.sh>`_. The rest of this
README is left as was written by Adafruit and contributors upstream.

Currently targeted upstream tag: `6.0.0
<https://github.com/adafruit/circuitpython/tree/6.0.0>`_.

CircuitPython
=============

.. image:: https://s3.amazonaws.com/adafruit-circuit-python/CircuitPython_Repo_header_logo.png

|Build Status| |Doc Status| |License| |Discord| |Weblate|

`circuitpython.org <https://circuitpython.org>`__ \| `Get CircuitPython <#get-circuitpython>`__ \|
`Documentation <#documentation>`__ \| `Contributing <#contributing>`__ \|
`Branding <#branding>`__ \| `Differences from Micropython <#differences-from-micropython>`__ \|
`Project Structure <#project-structure>`__

**CircuitPython** is a *beginner friendly*, open source version of Python for tiny, inexpensive
computers called microcontrollers. Microcontrollers are the brains of many electronics including a
wide variety of development boards used to build hobby projects and prototypes. CircuitPython in
electronics is one of the best ways to learn to code because it connects code to reality. Simply
install CircuitPython on a supported board via drag and drop and then edit a ``code.py`` file on
the CIRCUITPY drive. The code will automatically reload. No software installs are needed besides a
text editor (we recommend `Mu <https://codewith.mu/>`_ for beginners.)

CircuitPython features unified Python core APIs and a growing list of 150+ device libraries and
drivers that work with it. These libraries also work on single board computers with regular
Python via the `Adafruit Blinka Library <https://github.com/adafruit/Adafruit_Blinka>`_.

CircuitPython is based on `MicroPython <https://micropython.org>`_. See
`below <#differences-from-micropython>`_ for differences. CircuitPython development is sponsored by
`Adafruit <https://adafruit.com>`_ and is available on their educational development boards. Please
support both MicroPython and Adafruit.

Get CircuitPython
------------------

Official binaries for all supported boards are available through
`circuitpython.org/downloads <https://circuitpython.org/downloads>`_. The site includes stable, unstable and
continuous builds. Full release notes and assets are available through
`GitHub releases <https://github.com/adafruit/circuitpython/releases>`_ as well.

Documentation
-------------

Guides and videos are available through the `Adafruit Learning
System <https://learn.adafruit.com/>`__ under the `CircuitPython
category <https://learn.adafruit.com/category/circuitpython>`__. An API
reference is also available on `Read the Docs
<http://circuitpython.readthedocs.io/en/latest/?>`__. A collection of awesome
resources can be found at `Awesome CircuitPython <https://github.com/adafruit/awesome-circuitpython>`__.

Specifically useful documentation when starting out:

- `Welcome to CircuitPython <https://learn.adafruit.com/welcome-to-circuitpython>`__
- `CircuitPython Essentials <https://learn.adafruit.com/circuitpython-essentials>`__
- `Example Code <https://github.com/adafruit/Adafruit_Learning_System_Guides/tree/master/CircuitPython_Essentials>`__

Contributing
------------

See
`CONTRIBUTING.md <https://github.com/adafruit/circuitpython/blob/main/CONTRIBUTING.md>`__
for full guidelines but please be aware that by contributing to this
project you are agreeing to the `Code of
Conduct <https://github.com/adafruit/circuitpython/blob/main/CODE_OF_CONDUCT.md>`__.
Contributors who follow the `Code of
Conduct <https://github.com/adafruit/circuitpython/blob/main/CODE_OF_CONDUCT.md>`__
are welcome to submit pull requests and they will be promptly reviewed
by project admins. Please join the
`Discord <https://adafru.it/discord>`__ too.

Branding
------------

While we are happy to see CircuitPython forked and modified, we'd appreciate it if forked releases
not use the name "CircuitPython" or the Blinka logo. "CircuitPython" means something special to
us and those who learn about it. As a result, we'd like to make sure products referring to it meet a
common set of requirements.

If you'd like to use the term "CircuitPython" and Blinka for your product here is what we ask:

* Your product is supported by the primary
  `"adafruit/circuitpython" <https://github.com/adafruit/circuitpython>`_ repo. This way we can
  update any custom code as we update the CircuitPython internals.
* Your product is listed on `circuitpython.org <https://circuitpython.org>`__ (source
  `here <https://github.com/adafruit/circuitpython-org/>`_). This is to ensure that a user of your
  product can always download the latest version of CircuitPython from the standard place.
* Your product has a user accessible USB plug which appears as a CIRCUITPY drive when plugged in.

If you choose not to meet these requirements, then we ask you call your version of CircuitPython
something else (for example, SuperDuperPython) and not use the Blinka logo. You can say it is
"CircuitPython-compatible" if most CircuitPython drivers will work with it.

--------------

Differences from `MicroPython <https://github.com/micropython/micropython>`__
-----------------------------------------------------------------------------

CircuitPython:

-  Supports native USB on all boards, allowing file editing without special tools.
-  Supports only SAMD21, SAMD51, nRF52840, CXD56, STM32F4 and i.MX RT ports.
-  Floats (aka decimals) are enabled for all builds.
-  Error messages are translated into 10+ languages.
-  Does not support concurrency within Python (including interrupts and threading). Some concurrency
   is achieved with native modules for tasks that require it such as audio file playback.

Behavior
~~~~~~~~

-  The order that files are run and the state that is shared between
   them. CircuitPython's goal is to clarify the role of each file and
   make each file independent from each other.
-  ``boot.py`` (or ``settings.py``) runs only once on start up before
   USB is initialized. This lays the ground work for configuring USB at
   startup rather than it being fixed. Since serial is not available,
   output is written to ``boot_out.txt``.
-  ``code.py`` (or ``main.py``) is run after every reload until it
   finishes or is interrupted. After it is done running, the vm and
   hardware is reinitialized. **This means you cannot read state from**
   ``code.py`` **in the REPL anymore.** CircuitPython's goal for this
   change includes reduce confusion about pins and memory being used.
-  After ``code.py`` the REPL can be entered by pressing any key. It no
   longer shares state with ``code.py`` so it is a fresh vm.
-  Autoreload state will be maintained across reload.
-  Adds a safe mode that does not run user code after a hard crash or
   brown out. The hope is that this will make it easier to fix code that
   causes nasty crashes by making it available through mass storage
   after the crash. A reset (the button) is needed after its fixed to
   get back into normal mode.
-  RGB status LED indicating CircuitPython state, and errors through a sequence of colored flashes.
-  Re-runs ``code.py`` or other main file after file system writes over USB mass storage. (Disable with
   ``samd.disable_autoreload()``)
-  Entering the REPL after the main code is finished requires a key press which enters the REPL and
   disables autoreload.
-  Main is one of these: ``code.txt``, ``code.py``, ``main.py``,
   ``main.txt``
-  Boot is one of these: ``settings.txt``, ``settings.py``, ``boot.py``,
   ``boot.txt``

API
~~~

-  Unified hardware APIs. Documented
   `on ReadTheDocs <https://circuitpython.readthedocs.io/en/latest/shared-bindings/index.html>`_.
-  API docs are rST within the C files in ``shared-bindings``.
-  No ``machine`` API.

Modules
~~~~~~~

-  No module aliasing. (``uos`` and ``utime`` are not available as
   ``os`` and ``time`` respectively.) Instead ``os``, ``time``, and
   ``random`` are CPython compatible.
-  New ``storage`` module which manages file system mounts.
   (Functionality from ``uos`` in MicroPython.)
-  Modules with a CPython counterpart, such as ``time``, ``os`` and
   ``random``, are strict
   `subsets <https://circuitpython.readthedocs.io/en/latest/shared-bindings/time/__init__.html>`__
   of their `CPython
   version <https://docs.python.org/3.4/library/time.html?highlight=time#module-time>`__.
   Therefore, code from CircuitPython is runnable on CPython but not
   necessarily the reverse.
-  tick count is available as
   `time.monotonic() <https://circuitpython.readthedocs.io/en/latest/shared-bindings/time/__init__.html#time.monotonic>`__

--------------

Project Structure
-----------------

Here is an overview of the top-level source code directories.

Core
~~~~

The core code of
`MicroPython <https://github.com/micropython/micropython>`__ is shared
amongst ports including CircuitPython:

-  ``docs`` High level user documentation in Sphinx reStructuredText
   format.
-  ``drivers`` External device drivers written in Python.
-  ``examples`` A few example Python scripts.
-  ``extmod`` Shared C code used in multiple ports' modules.
-  ``lib`` Shared core C code including externally developed libraries
   such as FATFS.
-  ``logo`` The CircuitPython logo.
-  ``mpy-cross`` A cross compiler that converts Python files to byte
   code prior to being run in MicroPython. Useful for reducing library
   size.
-  ``py`` Core Python implementation, including compiler, runtime, and
   core library.
-  ``shared-bindings`` Shared definition of Python modules, their docs
   and backing C APIs. Ports must implement the C API to support the
   corresponding module.
-  ``shared-module`` Shared implementation of Python modules that may be
   based on ``common-hal``.
-  ``tests`` Test framework and test scripts.
-  ``tools`` Various tools, including the pyboard.py module.

Ports
~~~~~

Ports include the code unique to a microcontroller line and also
variations based on the board.

-  ``atmel-samd`` Support for SAMD21 and SAMD51 based boards.
-  ``nrf`` Support for the nRF52840 based boards.
-  ``unix`` Support for UNIX. Only used for automated testing.

The remaining port directories not listed above are in the repo to maintain compatibility with the
`MicroPython <https://github.com/micropython/micropython>`__ parent project.

`back to top <#circuitpython>`__

.. |Build Status| image:: https://github.com/adafruit/circuitpython/workflows/Build%20CI/badge.svg
   :target: https://github.com/adafruit/circuitpython/actions?query=branch%3Amain
.. |Doc Status| image:: https://readthedocs.org/projects/circuitpython/badge/?version=latest
   :target: http://circuitpython.readthedocs.io/
.. |Discord| image:: https://img.shields.io/discord/327254708534116352.svg
   :target: https://adafru.it/discord
.. |License| image:: https://img.shields.io/badge/License-MIT-brightgreen.svg
   :target: https://choosealicense.com/licenses/mit/
.. |Weblate| image:: https://hosted.weblate.org/widgets/circuitpython/-/svg-badge.svg
   :target: https://hosted.weblate.org/engage/circuitpython/?utm_source=widget
