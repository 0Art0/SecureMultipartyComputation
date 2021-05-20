from manim import *
from math import sin, cos, pi

config["tex_template"] = TexTemplateLibrary.simple

class BankLocker(Scene):
	def construct(self):
		numberplane = NumberPlane()

		(x, y) = 1.75, 2.5

		manager = Dot([x, y, 0])
		managertext = Text("Manager").next_to(manager)

		r = 1.25

		circle = Circle(arc_center = manager.get_center(), radius = r, color=GREEN_A)

		self.add(numberplane, manager)
		self.play(GrowFromCenter(managertext))
		self.wait(5)
		self.play(FadeOut(managertext))
		self.play(GrowFromCenter(circle))

		a, b = pi/3, -4*pi/9

		customer1 = Dot([x + r * cos(a), y + r * sin(a), 0])
		customer2 = Dot([x + r * cos(b), y + r * sin(b), 0])

		self.wait(2)

		self.play(FadeInFromLarge(customer1))
		self.play(FadeInFromLarge(customer2))

		self.wait(3)
		
		line = Line([x, y, 0], [x + r, y, 0]).set_color(ORANGE)
		b = Brace(line)
		btext = b.get_text("r")

		self.play(FadeInFromLarge(line), FadeInFromLarge(b), FadeIn(btext))

		self.wait(3)