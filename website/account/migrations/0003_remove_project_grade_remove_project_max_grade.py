# Generated by Django 5.1.1 on 2024-11-04 14:23

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0002_project_user_image_user_projects'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='project',
            name='grade',
        ),
        migrations.RemoveField(
            model_name='project',
            name='max_grade',
        ),
    ]
