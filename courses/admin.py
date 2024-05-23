from django.contrib import admin
from django import forms
from django.utils.html import mark_safe
from .models import Category,Course,Lesson,Tag,User
from ckeditor_uploader.widgets import CKEditorUploadingWidget
from django.contrib.auth.models import Permission
# Register your models here.

class LessonForm(forms.ModelForm):
    content = forms.CharField(widget=CKEditorUploadingWidget)
    class Meta:
        model = Lesson
        fields = '__all__'

class LessonTagInline(admin.TabularInline):
    model = Lesson.tags.through

class LessonAdmin(admin.ModelAdmin):
    class Media:
        css = {
            'all' : ('/static/css/main.css',)
        }
    form = LessonForm
    # list_display = ["id","subject","created_date","active","course"]
    search_fields = ["subject","created_date","course__subject"]
    list_filter = ["subject", "course__subject"]
    readonly_fields = ["avatar"]
    inlines = (LessonTagInline,)

    def avatar(self, lesson):
        return mark_safe("<img src='/static/{img_url}' alt='{alt}' width='120px' />".format(img_url=lesson.image.name, alt=lesson.subject))


class LessonInline(admin.StackedInline):
    model = Lesson
    pf_name = 'course'

class CourseAdmin(admin.ModelAdmin):
    inlines = (LessonInline,)


admin.site.register(Category)
admin.site.register(Course, CourseAdmin)
admin.site.register(Lesson, LessonAdmin)
admin.site.register(Tag)
admin.site.register(User)
admin.site.register(Permission)
