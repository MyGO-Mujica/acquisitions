import logger from '#config/logger.js';
import { db } from '#config/database.js';
import { users } from '#models/user.model.js';
import { eq } from 'drizzle-orm';

export const getAllUsers = async () => {
  try {
    return await db
      .select({
        id: users.id,
        email: users.email,
        name: users.name,
        role: users.role,
        created_at: users.created_at,
        updated_at: users.updated_at,
      })
      .from(users);
  } catch (e) {
    logger.error('获取所有用户时发生错误', e);
    throw e;
  }
};

export const getUserById = async id => {
  try {
    const [user] = await db
      .select({
        id: users.id,
        email: users.email,
        name: users.name,
        role: users.role,
        created_at: users.created_at,
        updated_at: users.updated_at,
      })
      .from(users)
      .where(eq(users.id, id))
      .limit(1);

    if (!user) {
      throw new Error('User not found');
    }

    return user;
  } catch (e) {
    logger.error(`根据ID获取用户(${id})时发生错误:`, e);
    throw e;
  }
};

export const updateUser = async (id, updates) => {
  try {
    // First check if user exists
    const existingUser = await getUserById(id);

    // Check if email is being updated and if it already exists
    if (updates.email && updates.email !== existingUser.email) {
      const [emailExists] = await db
        .select()
        .from(users)
        .where(eq(users.email, updates.email))
        .limit(1);
      if (emailExists) {
        throw new Error('Email already exists');
      }
    }

    // Add updated_at timestamp
    const updateData = {
      ...updates,
      updated_at: new Date(),
    };

    const [updatedUser] = await db
      .update(users)
      .set(updateData)
      .where(eq(users.id, id))
      .returning({
        id: users.id,
        email: users.email,
        name: users.name,
        role: users.role,
        created_at: users.created_at,
        updated_at: users.updated_at,
      });

    logger.info(`用户 ${updatedUser.email} 信息更新成功 (Service)`);
    return updatedUser;
  } catch (e) {
    logger.error(`更新用户(${id})时发生错误:`, e);
    throw e;
  }
};

export const deleteUser = async id => {
  try {
    // First check if user exists
    await getUserById(id);

    const [deletedUser] = await db
      .delete(users)
      .where(eq(users.id, id))
      .returning({
        id: users.id,
        email: users.email,
        name: users.name,
        role: users.role,
      });

    logger.info(`用户 ${deletedUser.email} 删除成功 (Service)`);
    return deletedUser;
  } catch (e) {
    logger.error(`删除用户(${id})时发生错误:`, e);
    throw e;
  }
};
