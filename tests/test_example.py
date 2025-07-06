from _pytest.capture import CaptureFixture

from example_project.__main__ import main


def test_main(capsys: CaptureFixture[str]) -> None:
    main()

    assert capsys.readouterr().out == 'Hello world!\n'
